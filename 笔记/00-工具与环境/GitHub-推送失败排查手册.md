# GitHub 推送失败排查手册（国内网络）

> 记录于 2026-10-10 ｜ 症状：`git push` 反复失败，但 `api.github.com` 完全正常
>
> 这份文档的价值：**下次再遇到，5 分钟内定位**，不用重新摸索一遍。

---

## 一、症状长什么样

```
fatal: unable to access 'https://github.com/<user>/<repo>.git/':
       Recv failure: Connection was reset
fatal: unable to access 'https://github.com/<user>/<repo>.git/':
       Failed to connect to github.com port 443 after 21074 ms: Could not connect to server
```

**关键特征**：同一条网络里，`api.github.com` 一切正常（GitHub API 调用、MCP 握手、建仓库都能成功），只有 `github.com` 的 git 操作失败。

> 这个"一半能通一半不通"的现象就是最大的线索 —— 它排除了"整体断网"，指向**针对特定域名的阻断**。

---

## 二、五步诊断（照抄命令）

### 第 1 步：区分 TCP 层和 TLS 层

```powershell
# TCP 握手（只看端口能不能连上）
Test-NetConnection -ComputerName github.com -Port 443 -InformationLevel Quiet
```

**结果解读**：

| 结果 | 含义 |
|---|---|
| `False` 且比较 github.com 与 api.github.com | 域名级阻断，继续第 2 步 |
| `True` 但 git 报 `Connection was reset` | **TCP 通、TLS 被重置** → 典型的 SNI 阻断（最常见） |

### 第 2 步：对照测试各个 GitHub 域名

```powershell
foreach($h in @('github.com','api.github.com','ssh.github.com','codeload.github.com')){
  $r = Test-NetConnection -ComputerName $h -Port 443 -InformationLevel Quiet -WarningAction SilentlyContinue
  Write-Output ("{0,-22} : {1}" -f $h, $(if($r){'通'}else{'不通'}))
}
```

**本次实测结果**：

| 域名 | 端口 | 结果 | 说明 |
|---|---|---|---|
| `github.com` | 443 | ⚠️ TCP 通，但 TLS 被重置 | git 推送走这里，被阻断 |
| `api.github.com` | 443 | ✅ 完全可用 | REST API 走这里，不受影响 |
| `ssh.github.com` | 443 | ✅ 可用（SSH 握手成功） | **逃生通道** |

### 第 3 步：确认 SSH 逃生通道真的能跑 SSH

```powershell
ssh -o BatchMode=yes -o ConnectTimeout=15 -p 443 -T git@ssh.github.com
```

**结果解读**：

| 输出 | 含义 |
|---|---|
| `Permission denied (publickey)` | ✅ **链路完全正常**，只是公钥没注册到 GitHub |
| `Connection timed out` / `reset` | ❌ 这条路也不通，只能上代理 |

### 第 4 步：查代理配置与进程

```powershell
# 系统代理（浏览器用）
Get-ItemProperty 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings' |
  Select-Object ProxyEnable, ProxyServer, AutoConfigURL

# git 自己的代理（git 不读系统代理！）
git config --show-origin --get-all http.proxy
git config --show-origin --get-all credential.helper

# 本机监听端口，找代理
Get-NetTCPConnection -State Listen | Where-Object LocalPort -in 7890,7897,10809,1080
```

> ⚠️ **最容易踩的坑**：`ProxyEnable=1 / ProxyServer=127.0.0.1:7890` 只对浏览器生效，**git 默认不读这个设置**。所以"浏览器能上 GitHub，git 推不上去"是常态，不是玄学。

### 第 5 步：确认代理真的在监听

```powershell
Get-NetTCPConnection -State Listen -ErrorAction SilentlyContinue |
  Where-Object LocalPort -eq 7890
```

**本次结果**：系统代理指向 `127.0.0.1:7890`，但**该端口没有任何进程监听** —— 代理软件（原来的 `Clash for Windows`）已经不在本机了。系统代理设置是**残留**的。

> 这也解释了一个迷惑现象：**40 分钟前两次 `git push` 成功了，之后连续 30 多次失败**。
> 原因是这类阻断是**间歇性**的 —— 同一个域名会在"能通"和"被重置"之间来回切换。

---

## 三、三种解决方案（按推荐度排序）

### 方案 A：SSH over 443（**不需要代理，最稳**）

原理：`ssh.github.com:443` 走的是纯 SSH 协议，**握手包里没有 SNI**，所以基于域名的阻断抓不到它。

#### A-1 注册 SSH 公钥

```powershell
# 复制公钥
Get-Content "$env:USERPROFILE\.ssh\id_ed25519.pub" | Set-Clipboard
```

打开 <https://github.com/settings/ssh/new> → Title 随便填（如 `home-desktop`）→ Key 粘贴 → Add SSH key。

> 如果连 github.com 网页也打不开（同一套 SNI 阻断），就只能先在能上网的环境（手机热点 / 代理）完成这一步，或者走 A-3。

#### A-2 把 SSH 指向 443 端口

编辑 `C:\Users\<你>\.ssh\config`：

```
Host github.com
  HostName ssh.github.com
  Port 443
  User git
  IdentityFile ~/.ssh/id_ed25519
  StrictHostKeyChecking accept-new
```

#### A-3 验证并切换 remote

```powershell
ssh -T git@github.com
# 期望：Hi gagahaolihai! You've successfully authenticated, but GitHub does not provide shell access.

cd "C:\Users\嘎嘎在这里\Desktop\java全栈"
git remote set-url origin git@github.com:gagahaolihai/java-backend-90days.git
git push
```

**好处**：之后再也不需要 PAT、不需要代理，`git push` 永远可用。

---

### 方案 B：给 git 配上代理

前提：本机有代理软件在跑（Clash / v2rayN / mihomo 等）。

```powershell
# 假设代理监听 127.0.0.1:7890
git config --global http.https://github.com.proxy http://127.0.0.1:7890
git config --global https.https://github.com.proxy http://127.0.0.1:7890

# 验证
git config --global --get http.https://github.com.proxy

# 取消（以后走直连）
git config --global --unset http.https://github.com.proxy
git config --global --unset https.https://github.com.proxy
```

> 上面用的是**按域名生效**的写法（`http.https://github.com.proxy`）而不是 `http.proxy`。区别：前者只对 github.com 走代理，访问公司内网 Git 时不会被误伤。

---

### 方案 C：重试（利用间歇窗口）

这类阻断是间歇性的。写个循环一直试，命中窗口就成功：

```powershell
$w = "C:\Users\嘎嘎在这里\Desktop\java全栈"
for($i=1; $i -le 60; $i++){
  git -C $w push 2>&1 | Write-Output
  if($LASTEXITCODE -eq 0){ "✅ 第 $i 次成功"; break }
  Start-Sleep -Seconds 20
}
```

**实测效果**：本次在 30 分钟内未命中窗口，但不失为临时手段。

---

### 方案 D：走 REST API 绕过 github.com（**权限受限时用不了**）

理论上可以用 Git Data API（`POST /git/blobs` → `/git/trees` → `/git/commits` → `PATCH /git/refs`）把提交直接推上去，因为 `api.github.com` 是通的。

**但本机实测失败**：fine-grained token 报 `403`，`x-accepted-github-permissions: contents=write`。

奇怪的是**同一个 token 用 `git push` 是能成功的**（成功过两次）。结论：
- `Contents: write` 对 **git 协议**有效
- 但对 **REST Git Data API** 不生效

> 记住这个差异：**"能 git push" ≠ "能用 API 写文件"**。

---

## 四、判断流程速查

```
git push 失败
    │
    ├─ api.github.com 也不通？ ──→ 整体断网，查网络/DNS
    │
    └─ 只有 github.com 不通
            │
            ├─ Test-NetConnection github.com 443 为 True，
            │  但 git 报 Connection was reset
            │        └─→ SNI 阻断
            │
            ├─ ssh -p 443 git@ssh.github.com 返回 Permission denied (publickey)？
            │        └─ 是 ──→ 【方案 A】注册公钥 + 走 443，一劳永逸 ✅
            │
            ├─ 本机有代理在跑？ ──→ 【方案 B】git config 配代理
            │
            └─ 都没有 ──→ 【方案 C】循环重试，同时考虑装个代理
```

---

## 五、本次事件时间线（真实记录）

| 时间 | 事件 |
|---|---|
| 19:5x | 两次 `git push` **成功**（`1e231c4..d2997df`、`d2997df..3a4e235`） |
| 之后 | 新增 11 个文件（W1 任务书）并提交，`git push` 开始失败 |
| +30min | 连续 34 次失败：`Connection was reset` / `Failed to connect after 21s` |
| 诊断 | 发现 `api.github.com` 通、`github.com` TLS 被重置、`ssh.github.com:443` 可用 |
| 同时发现 | 系统代理指向 `127.0.0.1:7890` 但无进程监听；`Clash for Windows` 目录已空 → 代理软件已不存在 |
| 尝试 | REST API 推送 → `403`（token 权限模型与 git 协议不一致） |
| 结论 | 走【方案 A】需要先注册 SSH 公钥（token 缺 `keys=write`，无法代注册） |

**本机 SSH 公钥**（需要注册的那个）：

```
ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIILBWHLkIlAfVK7RPrGwOfUiElr8r/pBNq2f9Dvf1Oif 1956294275@qq.com
```

---

## 六、命令速查

| 目的 | 命令 |
|---|---|
| 测 TCP | `Test-NetConnection github.com -Port 443 -InformationLevel Quiet` |
| 测 SSH 443 | `ssh -o BatchMode=yes -p 443 -T git@ssh.github.com` |
| 看系统代理 | `Get-ItemProperty 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings'` |
| 看 git 代理 | `git config --show-origin --get-all http.proxy` |
| 看监听端口 | `Get-NetTCPConnection -State Listen \| Where-Object LocalPort -eq 7890` |
| 强制 HTTP/1.1 | `git -c http.version=HTTP/1.1 push` |
| 禁止交互输密码 | `$env:GIT_TERMINAL_PROMPT=0` |
| 看 remote | `git remote -v` |
| 切 SSH | `git remote set-url origin git@github.com:<user>/<repo>.git` |

---

## 七、教训（写给自己）

1. **"能通"和"能用"是两回事**：`Test-NetConnection` 只做 TCP 握手，TLS 层被重置它测不出来。判断网络问题必须做到应用层。
2. **`api.github.com` 通 ≠ `github.com` 通**：GitHub 的 API 域名和 git 域名是分开的，阻断策略也不同。
3. **浏览器能上不代表命令行能上**：git 不读 Windows 系统代理，这是两套配置。
4. **"能 git push" ≠ "能用 REST API 写"**：fine-grained token 对这两条路的权限判定不一致。
5. **间歇性故障要有耐心也要有记录**：正因为前两次成功了，才排除了"配置全错"的可能，把范围缩到"网络阻断"。
