# GitHub 推送失败排查手册（DNS 污染 / IP 阻断）

> 首次记录 2026-10-10 ｜ 症状：`git push` 反复失败，但 `api.github.com` 完全正常
>
> **本文档经过一次结论纠正**：最初的判断是「SNI 阻断」，后来被实验推翻。纠正过程保留在第五节 —— **排查方法论比结论更值得学**。

---

## 一、症状

```
fatal: unable to access 'https://github.com/<user>/<repo>.git/':
       Failed to connect to github.com port 443 after 21074 ms: Could not connect to server
fatal: unable to access 'https://github.com/<user>/<repo>.git/':
       Recv failure: Connection was reset
```

**关键特征**：同一条网络里 `api.github.com` 一切正常（GitHub API、MCP 握手、建仓库都成功），只有 `github.com` 的 git 操作失败。

另外还有一个迷惑现象：**同一台机器，40 分钟前两次 push 成功，之后连续 34 次失败。**

## 二、根因（一句话）

**系统 DNS 把 `github.com` 解析到了 `20.205.243.166`，而这个 IP 上的 TLS 连不通；换成 GitHub 的其它 IP（如 `140.82.112.3`）立刻恢复正常。**

也就是说：**问题出在"解析到哪个 IP"，不在域名、不在证书、不在 SNI。**

## 三、诊断五步（照抄可用）

### 第 1 步：分清"TCP 通"和"TLS 通"

```powershell
Test-NetConnection -ComputerName github.com -Port 443 -InformationLevel Quiet
```

**本次结果：`True`** —— 但 git 依然失败。

> ⚠️ **这是最大的陷阱**：`Test-NetConnection` 只做 TCP 三次握手。TCP 通了不代表能发 HTTPS 请求。
> **判断网络问题必须做到应用层**，否则会被"端口是通的"误导一整天。

### 第 2 步：对照各个 GitHub 域名

```powershell
foreach($h in @('github.com','api.github.com','ssh.github.com')){
  $r = Test-NetConnection -ComputerName $h -Port 443 -InformationLevel Quiet -WarningAction SilentlyContinue
  Write-Output ("{0,-20} : {1}" -f $h, $(if($r){'TCP 通'}else{'不通'}))
}
```

### 第 3 步（**关键**）：固定 IP 做 TLS 实测

这一步是整次排查的转折点。用 Node 直接对指定 IP 发起 TLS 请求（`servername` 仍是 `github.com`，所以 SNI 不变）：

```javascript
// test.js —— 用法: node test.js
const https=require("https");
const ips=["140.82.112.3","140.82.113.3","140.82.114.3","140.82.121.3","20.205.243.166","140.82.116.3"];
const test=(ip)=>new Promise(res=>{
  const lookup=(h,o,cb)=> o&&o.all ? cb(null,[{address:ip,family:4}]) : cb(null,ip,4);
  const req=https.get({host:"github.com",port:443,path:"/",servername:"github.com",lookup,timeout:8000,
    headers:{"user-agent":"probe"}},
    r=>{r.resume();res(ip.padEnd(18)+" -> HTTP "+r.statusCode+" ✅");});
  req.on("timeout",()=>{req.destroy();res(ip.padEnd(18)+" -> 超时 ❌");});
  req.on("error",e=>res(ip.padEnd(18)+" -> ✗ "+(e.code||e.message)));
});
(async()=>{ for(const ip of ips) console.log(await test(ip)); })();
```

**本次实测结果**：

| IP | 结果 |
|---|---|
| `140.82.112.3` | ✅ HTTP 200 |
| `140.82.113.3` | ✅ HTTP 200 |
| `140.82.114.3` | ✅ HTTP 200 |
| `140.82.121.3` | ✅ HTTP 200 |
| `140.82.116.3` | ✅ HTTP 200 |
| **`20.205.243.166`**（DNS 实际返回的） | ❌ 超时 |

**结论**：SNI 全程都是 `github.com`，换 IP 就能通 —— **直接排除了 SNI 阻断**。

### 第 4 步：确认 git 有没有能力绕过 DNS

```powershell
git -c http.curloptResolve="github.com:443:140.82.112.3" ls-remote https://github.com/<user>/<repo>.git
```

**本次结果**：**成功返回 refs**（Git 2.54 支持 `http.curloptResolve`）。
对照组不加这个参数 → `exit=128` 失败。

> 这一步验证了"有解"，而且不用改系统、不用管理员权限。

### 第 5 步：查 DNS 返回了什么

```powershell
Resolve-DnsName github.com -Type A | Where-Object IPAddress | Select-Object Name,IPAddress
```

本次返回 `20.205.243.166` —— 就是那个 TLS 不通的 IP。

---

## 四、解决方案

### ✅ 方案 A：`git config http.curloptResolve` 固定 IP（**已配置，立即可用**）

这是本次采用的方案。**只影响本仓库，不动系统设置，不需要管理员权限。**

```powershell
cd "C:\Users\嘎嘎在这里\Desktop\java全栈"
git config http.curloptResolve "github.com:443:140.82.112.3"

# 之后正常推送即可
git push
```

确认已生效：

```powershell
git config --get http.curloptResolve
```

**取消**（等 DNS 恢复正常后）：

```powershell
git config --unset http.curloptResolve
```

#### ⚠️ 这个方案的缺点

**硬编码 IP 会过期。** GitHub 的 IP 会变，写死的 IP 某天可能失效。所以配套写了一个自动探测脚本，见第六节。

---

### 方案 B：改 hosts 文件（系统级，推荐长期方案，**需要管理员权限**）

用记事本**以管理员身份**打开 `C:\Windows\System32\drivers\etc\hosts`，追加：

```
140.82.112.3  github.com
140.82.112.3  api.github.com
```

保存后刷新 DNS：

```powershell
ipconfig /flushdns
```

**优点**：所有程序（git、浏览器、其它工具）都受益，不用逐个配置。
**缺点**：需要管理员；同样有 IP 过期的风险。

> 本次**没能采用**：当前进程无管理员权限，`hosts` 文件写入被拒绝。

---

### 方案 C：换 DNS 服务器

污染通常来自运营商 DNS。改用公共 DNS 往往能拿到正确 IP：

- 阿里 DNS：`223.5.5.5` / `223.6.6.6`
- 腾讯 DNS：`119.29.29.29`
- 114 DNS：`114.114.114.114`

改的地方：`设置 → 网络和 Internet → 适配器选项 → 属性 → IPv4 → 使用下面的 DNS 服务器地址`。

改完必须刷新缓存：

```powershell
ipconfig /flushdns
```

> **注意**：某些污染是**出口层**做的，改本地 DNS 无效。改完先测 `Resolve-DnsName github.com`，看返回的 IP 变没变。

---

### 方案 D：走代理

前提：本机有代理软件在运行。

```powershell
# 系统代理（Clash 等）默认只对浏览器生效，git 不读它！必须单独配
git config --global http.https://github.com.proxy http://127.0.0.1:7890
git config --global https.https://github.com.proxy http://127.0.0.1:7890

# 取消
git config --global --unset http.https://github.com.proxy
git config --global --unset https.https://github.com.proxy
```

**本次的坑**：系统代理设置里写着 `ProxyEnable=1 / ProxyServer=127.0.0.1:7890`，但**那个端口根本没有进程监听** —— 代理软件（`Clash for Windows`）已经不在这台机器上了，系统设置是残留。

> 记住：**"浏览器能上 GitHub"≠"git 能上"**。git 不读 Windows 系统代理，这是两套独立配置。

---

### 方案 E：SSH over 443（不需要代理，但需要先注册公钥）

`ssh.github.com:443` 走纯 SSH 协议，**握手包里没有 SNI**，因此不受 DNS/SNI 类干扰影响。

```powershell
# 验证链路（本次实测：返回 Permission denied (publickey) = 链路完全正常）
ssh -o BatchMode=yes -o ConnectTimeout=15 -p 443 -T git@ssh.github.com
```

步骤：
1. 复制公钥：`Get-Content "$env:USERPROFILE\.ssh\id_ed25519.pub" | Set-Clipboard`
2. 粘到 <https://github.com/settings/ssh/new>
3. 编辑 `~/.ssh/config`：

```
Host github.com
  HostName ssh.github.com
  Port 443
  User git
  IdentityFile ~/.ssh/id_ed25519
  StrictHostKeyChecking accept-new
```

4. 切换 remote 并推送：

```powershell
git remote set-url origin git@github.com:<user>/<repo>.git
ssh -T git@github.com      # 期望：Hi <user>! You've successfully authenticated...
git push
```

**本次没能采用**：本机有 `~/.ssh/id_ed25519`，但公钥没注册到 GitHub；而代注册需要 PAT 具备 `keys=write`（账号级权限），当前 token 没有。

> **这个方案一次配好，永久有效**，不依赖 IP、不依赖代理、不需要 PAT。强烈建议有空时配掉。

---

### ❌ 方案 F：走 REST API 绕过 github.com（本次实测失败）

理论上可用 Git Data API 直接推提交（`POST /git/blobs` → `/git/trees` → `/git/commits` → `PATCH /git/refs`），因为 `api.github.com` 是通的。思路正确，但**被权限挡住**：

```
POST /git/blobs    → 403  需要: contents=write
POST /git/trees    → 403  需要: contents=write
POST /git/commits  → 403  需要: contents=write
PUT  /contents/x   → 403  需要: contents=write
```

**但同一个 token 用 `git push` 是成功的。** 这个矛盾值得记住：

> **「能 git push」≠「能用 REST API 写文件」。** fine-grained token 在 git 协议和 REST API 两条路上的权限判定不一致。

---

## 五、判断流程速查

```
git push 失败
    │
    ├─ api.github.com 也不通？ ──→ 整体断网，查网线/WiFi/DNS
    │
    └─ 只有 github.com 不通
            │
            ├─ Test-NetConnection 为 True 但 git 失败
            │        └─→ TCP 通、应用层被卡。做【第 3 步：固定 IP 测试】
            │
            ├─ 固定到别的 GitHub IP 能通？
            │        └─ 是 ──→ 【方案 A】curloptResolve 固定 IP（本仓库已配）✅
            │                  或【方案 B】改 hosts（需管理员）
            │                  或【方案 C】换 DNS
            │
            ├─ 固定到任何 IP 都不通 ──→ 大概率真·SNI/出口阻断
            │        └─ 【方案 D】代理 或【方案 E】SSH over 443
            │
            └─ ssh -p 443 git@ssh.github.com 返回 Permission denied (publickey)？
                     └─ 是 ──→【方案 E】注册公钥 + 走 443，一劳永逸 ✅
```

---

## 六、配套脚本：自动探测可用 IP 并推送

`http.curloptResolve` 写死 IP 会过期。仓库里放了 [`工具/github-push.ps1`](../../工具/github-push.ps1)：

- 依次测试一组 GitHub IP 的**真实 TLS 连通性**（不只是 TCP）
- 挑第一个能用的，自动带上 `curloptResolve` 执行 `git push`
- 全部不通时给出明确提示，而不是让你对着 `Connection was reset` 猜

用法：

```powershell
cd "C:\Users\嘎嘎在这里\Desktop\java全栈"

# 探测并推送一次
powershell -NoProfile -ExecutionPolicy Bypass -File 工具\github-push.ps1

# 探测后固化到本仓库配置（之后 git push 直接可用）
powershell -NoProfile -ExecutionPolicy Bypass -File 工具\github-push.ps1 -Persist

# DNS 恢复正常后清除固化配置
powershell -NoProfile -ExecutionPolicy Bypass -File 工具\github-push.ps1 -Clear
```

> **`-ExecutionPolicy Bypass` 不能省。** Windows 默认执行策略禁止运行未签名脚本，否则报
> `... is not digitally signed. You cannot run this script on the current system.`
> （这只影响本次调用，不会降低系统的安全设置。）

> **脚本文件必须存成「UTF-8 带 BOM」。** Windows PowerShell 5.1 读取 `.ps1` 时，
> 如果文件没有 BOM，会**按系统 ANSI 编码（中文 Windows 是 GBK）解析**，
> 于是脚本里的中文全变成乱码（如 `鏈兘鏄`），轻则乱码输出，重则**引号/括号配对错乱导致语法报错**。
> 用 VS Code 保存时选「UTF-8 with BOM」；或用下面这行命令转换：
>
> ```powershell
> $p = "工具\github-push.ps1"
> $t = [IO.File]::ReadAllText($p, (New-Object Text.UTF8Encoding($false))).TrimStart([char]0xFEFF)
> [IO.File]::WriteAllText($p, $t, (New-Object Text.UTF8Encoding($true)))
> ```
>
> 检查前三个字节是不是 `EF BB BF`：
> ```powershell
> $b = [IO.File]::ReadAllBytes("工具\github-push.ps1"); '{0:X2} {1:X2} {2:X2}' -f $b[0],$b[1],$b[2]
> ```

---

## 七、命令速查

| 目的 | 命令 |
|---|---|
| 测 TCP（**不够，只是第一步**） | `Test-NetConnection github.com -Port 443 -InformationLevel Quiet` |
| 看 DNS 返回什么 IP | `Resolve-DnsName github.com -Type A \| Where-Object IPAddress` |
| 测 SSH over 443 | `ssh -o BatchMode=yes -p 443 -T git@ssh.github.com` |
| git 绕过 DNS 固定 IP | `git -c http.curloptResolve="github.com:443:140.82.112.3" push` |
| 查看已配的固定 IP | `git config --get http.curloptResolve` |
| 取消固定 IP | `git config --unset http.curloptResolve` |
| 看系统代理 | `Get-ItemProperty 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings'` |
| 看 git 代理 | `git config --show-origin --get-all http.proxy` |
| 查端口有没有真在监听 | `Get-NetTCPConnection -State Listen \| Where-Object LocalPort -eq 7890` |
| 刷新 DNS 缓存 | `ipconfig /flushdns` |
| 禁止交互输密码（避免卡住） | `$env:GIT_TERMINAL_PROMPT=0` |
| 强制 HTTP/1.1 | `git -c http.version=HTTP/1.1 push` |

---

## 八、本次事件时间线（真实记录）

| 时间 | 事件 |
|---|---|
| 19:5x | 两次 `git push` **成功**（`1e231c4..d2997df`、`d2997df..3a4e235`）—— 说明当时 DNS 恰好返回了好 IP |
| 之后 | 新增 11 个文件（W1 任务书）并提交，`git push` 开始持续失败 |
| +30min | 连续 34 次失败：`Connection was reset` / `Failed to connect after 21s` |
| 误判 | 看到「TCP 通、TLS 被重置」+「`api.github.com` 通」，**误判为 SNI 阻断** |
| 修正 | 做「固定 IP 测 TLS」实验：换 IP 就能通，而 SNI 全程不变 → **推翻 SNI 判断，确认是 DNS 解析问题** |
| 验证 | `git -c http.curloptResolve=... ls-remote` 成功，不加则失败 |
| 解决 | 写入仓库本地配置 `http.curloptResolve`，`git push` 恢复正常 |
| 结果 | `3a4e235..c5b2213` 推送成功，远端 5 个提交 / 39 个文件 |

---

## 九、教训

1. **`Test-NetConnection` 通 ≠ 能用。** 它只做 TCP 握手。判断网络问题必须**打到应用层**（发一次真的 HTTPS 请求）。
2. **一开始的判断可能是错的，要设计能推翻它的实验。** 我最初认为是 SNI 阻断，理由是"TCP 通但 TLS 被重置，且 api 域名正常"。真正推翻它的是**固定 IP 测试**：SNI 没变、只换了 IP 就通了 —— 一个变量，直接证伪。**排查就是不断设计单变量实验。**
3. **先找"能通的反例"。** 发现 `ssh.github.com:443` 和多个 GitHub IP 都能通，比继续猜原因有价值得多。
4. **浏览器能上 ≠ 命令行能上。** git 不读 Windows 系统代理，两套配置。
5. **「能 git push」≠「能用 REST API 写」。** 同一个 token 在两条路上的权限判定不一致。
6. **间歇性故障要记录时间线。** 正因为"前两次成功了"，才排除了"配置全错"，把范围缩到网络层。
