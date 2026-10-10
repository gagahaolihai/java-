# GitHub MCP 配置记录

> 目的：让 DSH 里的 AI 助手能**直接读写你的 GitHub 仓库**（建仓库、推文件、开 Issue/PR、写 Release），
> 这样每天的 Issue、每周的 tag 可以交给助手批量处理，你专心写代码。

配置完成于：2026-10-10 ｜ 关联任务：Day 0 环境准备 ｜ GitHub 账号：`gagahaolihai`

---

## 一、最终选型：官方远程 MCP 服务

| 方案 | 是否采用 | 原因 |
|---|---|---|
| **官方远程服务（Streamable HTTP）** | ✅ 采用 | 免 Docker、免拉镜像、免本地进程；官方维护，最新工具集 |
| Docker 本地跑 `ghcr.io/github/github-mcp-server` | ❌ | 每次要拉镜像、占资源，本机已能直连远程服务 |
| `npx @modelcontextprotocol/server-github` | ❌ | 该包**已归档弃用**，功能落后于官方 server |
| `gh` CLI + OAuth | ❌ | 需要额外装 CLI，且 DSH 的 MCP 配置只支持静态 Header 认证 |

- **服务地址**：`https://api.githubcopilot.com/mcp/`
- **认证方式**：请求头 `Authorization: Bearer <你的 PAT>`
- **实测**：不带 token 请求返回 `401`，带 `WWW-Authenticate: Bearer error="invalid_request"` —— 说明端点可达且认证机制符合预期

参考文档：[github/github-mcp-server · docs/remote-server.md](https://github.com/github/github-mcp-server/blob/main/docs/remote-server.md)

---

## 二、DSH 侧的配置（已完成）

写入位置：`C:\Users\<你>\.dsh\profiles\desktop\cordis.patch.yml`

```yaml
- id: mcp-github
  name: '@deepseek-ai/dsh-mcp-client'
  config:
    serverName: github
    transport: streamable-http
    url: https://api.githubcopilot.com/mcp/
    headers:
      Authorization: !!js '`Bearer ${process.env.GITHUB_MCP_PAT || "PASTE_YOUR_GITHUB_PAT_HERE"}`'
      X-MCP-Toolsets: repos,git,issues,pull_requests,labels
    toolCallTimeoutMs: 60000
    failOnStartupError: false
```

### 字段说明

| 字段 | 作用 |
|---|---|
| `serverName: github` | 工具名前缀，最终形如 `mcp__github__create_repository` |
| `transport: streamable-http` | 远端服务用 HTTP 传输；本地程序才用 `stdio` |
| `headers.Authorization` | PAT 认证。`!!js` 是 DSH 配置的**表达式标签**，在条目激活时求值 |
| `X-MCP-Toolsets` | **收窄工具集**。默认会把上百个工具全塞进模型上下文（浪费 token、干扰判断）。这里只要仓库/提交/Issue/PR/标签五类 |
| `toolCallTimeoutMs` | 单次工具调用超时 60s |
| `failOnStartupError: false` | Token 还没填时不阻塞 DSH 启动，只重连 |

> **改完这个文件不用重启 DSH**：profile 配置由 `dsh-hmr` 热重载。

### 为什么用 `X-MCP-Toolsets`

远程服务默认 toolset 包含大量你不需要的工具（Copilot、安全扫描、Gist、通知等）。可选 toolset 全量列表：
`actions, code_quality, code_security, copilot, discussions, gists, git, issues, labels, notifications, orgs, projects, pull_requests, repos, secret_protection, security_advisories, stargazers, users` 等。

本项目用到的五类：

| Toolset | 干什么 |
|---|---|
| `repos` | 建仓库、读写文件、查分支/提交 |
| `git` | 底层对象操作（整棵树推提交时用） |
| `issues` | 每天的任务 Issue、周复盘 Issue |
| `pull_requests` | 开 PR、看 diff、合并 |
| `labels` | 给 Issue 打标签（daily / weekly） |

---

## 三、创建 PAT（Personal Access Token）—— 你需要做的

### 推荐：Fine-grained token（权限最小化）

1. 打开 <https://github.com/settings/personal-access-tokens/new>
2. **Token name**：`dsh-github-mcp`
3. **Expiration**：`90 days`（学习期足够；过期重新生成即可）
4. **Resource owner**：选你自己的账号
5. **Repository access**：选 `All repositories`（或只勾学习仓库，更安全）
6. **Permissions**（展开 `Repository permissions`，只开这几项）：

   | 权限 | 级别 | 为什么需要 |
   |---|---|---|
   | `Metadata` | Read-only | **必选**，勾其他权限时会自动带上 |
   | `Contents` | Read and write | 推代码、建分支、写文件 |
   | `Issues` | Read and write | 建/关每日任务 Issue |
   | `Pull requests` | Read and write | 开 PR、合并 |
   | `Workflows` | Read and write | 只有需要让助手改 `.github/workflows/` 时才勾 |

   > Account permissions 一个都不用开。

7. 点 **Generate token**，复制 `github_pat_...` 开头的字符串（**只显示这一次**）

<details>
<summary>备选：Classic token（更简单，权限更粗）</summary>

<https://github.com/settings/tokens/new> → 勾 `repo` + `workflow` → 生成 `ghp_...`

安全边界比 fine-grained 粗，但配起来快。
</details>

### 安全提醒（重要）

- PAT 等同于你的账号密码（至少是仓库的全部读写权）。**不要**贴到聊天、Issue、截图、代码里
- 本仓库 `.gitignore` 已排除 `**/github-mcp.token`、`.env*`、`application-local.yml`，避免误提交
- 一旦怀疑泄漏：立刻到 <https://github.com/settings/tokens> 点 **Revoke**，然后重新生成

---

## 四、把 PAT 写进配置（二选一）

### 方式 A：本机执行命令（推荐，token 不进任何聊天记录）

在 **PowerShell** 里粘贴执行：

```powershell
$yml = "$env:USERPROFILE\.dsh\profiles\desktop\cordis.patch.yml"
$sec = Read-Host -Prompt '粘贴 GitHub PAT 后回车（输入时不显示）' -AsSecureString
$pat = [Runtime.InteropServices.Marshal]::PtrToStringBSTR([Runtime.InteropServices.Marshal]::SecureStringToBSTR($sec))
$c   = [IO.File]::ReadAllText($yml)
$c   = $c.Replace('PASTE_YOUR_GITHUB_PAT_HERE', $pat)
[IO.File]::WriteAllText($yml, $c, (New-Object Text.UTF8Encoding($false)))
Remove-Variable sec, pat, c -ErrorAction SilentlyContinue
'✅ 已写入，DSH 会自动热重载配置'
```

执行后应该看到 `✅ 已写入`。然后回来告诉我，我会调用一个 GitHub MCP 工具实测连通性。

### 方式 B：用环境变量（需要重启 DSH）

```powershell
# 设置用户级环境变量（永久生效）
[Environment]::SetEnvironmentVariable('GITHUB_MCP_PAT', '<你的PAT>', 'User')
```

配置里 `process.env.GITHUB_MCP_PAT` 优先于字面量。但**环境变量只在 DSH 进程启动时读取**，所以必须**完全退出并重启 DSH** 才生效（热重载不够）。

---

## 五、验证是否生效

1. 让 AI 助手调用一个 GitHub 工具，例如"列出我的仓库"或"查询我的 GitHub 用户信息"
2. 工具名形如 `mcp__github__*`，看到就是这个 MCP 在干活
3. 若报 `401`：token 没写进去 / 已过期 / 复制时带了空格
4. 若工具列表里看不到 `mcp__github__*`：检查 `cordis.patch.yml` 缩进（YAML 对缩进敏感），或看 DSH 是否提示该条目激活失败

### 常用工具速查

| 想做什么 | 工具 |
|---|---|
| 建仓库 | `mcp__github__create_repository` |
| 批量推文件（一次提交多个文件） | `mcp__github__push_files` |
| 读文件 | `mcp__github__get_file_contents` |
| 建 Issue / 关 Issue | `mcp__github__issue_write` |
| 开 PR / 合并 PR | `mcp__github__create_pull_request` / `merge_pull_request` |
| 建 Release | `mcp__github__create_release` |
| 查我的信息 | `mcp__github__get_me` |

---

## 六、收尾：Git 身份与首次提交

首次提交之前必须配好作者信息，否则历史里的作者名要重写。用 GitHub 的 noreply 隐私邮箱（不暴露真实邮箱，GitHub 仍能正确归属到你）：

```powershell
cd "C:\Users\嘎嘎在这里\Desktop\java全栈"
git config user.name "gagahaolihai"
git config user.email "gagahaolihai@users.noreply.github.com"
git add -A
git commit -m "chore: 初始化 90 天 Java 后端学习仓库（路线图 + 模板 + 目录骨架）"
git branch -M main
git log --oneline -1 --format="%an <%ae> | %s"
```

> ✅ 本仓库已完成这一步，首次提交为 `67896e9`。

### 关联远程仓库并推送

先在 GitHub 网页建一个**空仓库**（不要勾 README / .gitignore / License），名字建议 `java-backend-90days`。

> ⚠️ **实测更正**：本机虽然有 `~/.ssh/id_ed25519`，但**公钥还没注册到 GitHub**，`ssh -T git@github.com` 返回 `Permission denied (publickey)`。所以目前 SSH 推送**用不了**，先用 HTTPS + PAT。

```powershell
cd "C:\Users\嘎嘎在这里\Desktop\java全栈"
git remote add origin https://github.com/gagahaolihai/java-backend-90days.git
git push -u origin main
```

<details>
<summary><b>推荐：一次性把 SSH 修好，以后推代码再也不用管 token</b></summary>

1. 复制公钥：
   ```powershell
   Get-Content "$env:USERPROFILE\.ssh\id_ed25519.pub" | Set-Clipboard
   ```
2. 打开 <https://github.com/settings/ssh/new>，Title 随便填（如 `home-desktop`），Key 粘贴，保存
3. 验证：
   ```powershell
   ssh -T git@github.com     # 期望：Hi gagahaolihai! You've successfully authenticated...
   git remote set-url origin git@github.com:gagahaolihai/java-backend-90days.git
   ```
4. 之后 `git push` 不需要任何凭据。
</details>

---

## 七、实测结果（2026-10-10 验证）

| 检查项 | 结果 |
|---|---|
| 端点可达 | ✅ POST 未带 token 返回 `401` + `WWW-Authenticate`，符合预期 |
| YAML 合法性 | ✅ 用 js-yaml 按 DSH 的 schema（注册 `!!js` 自定义标签）解析通过 |
| `!!js` 求值 | ✅ 按 DSH 源码 `new Function("ctx","expr","with (ctx) { return eval(expr) }")` 复现，得到 `Bearer github_pat_…` |
| MCP 握手 | ✅ `initialize` → 200，返回 `mcp-session-id`，协商到 `protocolVersion 2025-06-18`，server 为 `github-mcp-server` |
| `tools/list` | ✅ 返回 **42 个工具**，正好是收窄后的 `repos,git,issues,pull_requests,labels` 五类 |
| Token 身份 | ✅ `GET /user` → 200，登录名 `gagahaolihai` |
| 建仓库权限 | ❌ `403 Resource not accessible by personal access token`，响应头 `x-accepted-github-permissions: administration=write; repository_creation=write` |

### 已验证可用的关键工具

`create_repository` · `push_files` · `create_or_update_file` · `create_branch` · `get_file_contents` · `get_repository_tree` · `list_commits` · `issue_read` · `issue_write` · `list_issues` · `create_pull_request` · `merge_pull_request` · `pull_request_read` · `label_write` · `search_code` · `search_repositories`

### 两个必须知道的注意点

**1. 建仓库要多一项权限。** fine-grained token 想调用 `create_repository`，必须额外勾 `Administration: Read and write`（`repository_creation: write`）。不勾也行——**手动在网页建好空仓库**即可，此后的推文件、开 Issue/PR 全部不受影响。两种做法可选其一，不要为了省一次点击去放宽 token 权限。

**2. MCP 工具只在新会话可见。** profile 配置支持热重载，但**当前已打开的会话不会刷新工具表**。填好 token 后需要**新开一个会话**才能看到 `mcp__github__*` 工具；若新会话仍看不到，再完全退出并重启 DSH。

---

## 八、踩坑记录

| 现象 | 原因 | 解决 |
|---|---|---|
| `POST /user/repos` 返回 `403 Resource not accessible by personal access token` | fine-grained token 没开 `Administration: Read and write`（`repository_creation: write`）。**读权限正常不代表有建仓库权限** | 要么在网页手动建空仓库，要么回到 token 设置补勾这项 |
| 配好了但工具表里看不到 `mcp__github__*` | 已打开的会话不会刷新工具表 | 新开一个会话；仍不行则重启 DSH |
| **浏览器直接打开 `https://api.githubcopilot.com/mcp/` 显示 `request: missing required Authorization header`** | **这是正常的，不是配置错误。** 它是 MCP 的 POST 接口：必须用 `Authorization: Bearer <PAT>` 且携带 JSON-RPC 请求体（`initialize`）。浏览器地址栏发的是不带认证头的 GET，服务端当然拒绝 | 不用管。判断端点是否可用要看"带合法 PAT 时能否握手成功"，见第七节实测结果 |
| 从 PowerShell 5.1 请求 `https://api.githubcopilot.com` 报"基础连接已关闭" | PS 5.1 默认不启用 TLS 1.2 | `[Net.ServicePointManager]::SecurityProtocol=[Net.SecurityProtocolType]::Tls12`；或用 Node/curl 测 |
| `raw.githubusercontent.com` 拉取失败 | 该域名网络受限 | 改用 `https://api.github.com/repos/<owner>/<repo>/contents/<path>` + `Accept: application/vnd.github.raw` |
| MCP 工具列表长得吓人 | 用了默认全量 toolset | 加 `X-MCP-Toolsets` 收窄 |
| `ssh -T git@github.com` 报 `Permission denied (publickey)` | 本机 `~/.ssh/id_ed25519.pub` 还没注册到 GitHub | GitHub → Settings → SSH and GPG keys → New SSH key，粘贴公钥；之后 git 走 SSH 就再也不用管 token |
