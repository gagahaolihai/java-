<#
.SYNOPSIS
    在国内网络环境下可靠地推送到 GitHub —— 自动探测可用的 GitHub IP 并绕过 DNS 污染。

.DESCRIPTION
    背景：系统 DNS 可能把 github.com 解析到一个 TLS 连不通的 IP（DNS 污染 / 定向阻断），
    表现为 `git push` 报 "Connection was reset" 或 "Failed to connect ... after 21s"，
    但 `api.github.com` 一切正常。

    本脚本用 `git ls-remote` 对一组 GitHub IP 做**真实的应用层连通性测试**
    （不是 Test-NetConnection 那种只握手 TCP 的假阳性测试），
    挑出第一个能用的 IP，带上 http.curloptResolve 执行推送。

.PARAMETER Remote
    远程名，默认 origin。

.PARAMETER Branch
    分支名，默认当前分支。

.PARAMETER Persist
    把探测到的 IP 写入本仓库的 git 配置（http.curloptResolve），之后直接 `git push` 即可。
    IP 会过期，建议配合 -Clear 使用。

.PARAMETER Clear
    清除本仓库已固化的 http.curloptResolve（DNS 恢复正常后用）。

.EXAMPLE
    powershell -File 工具\github-push.ps1
    探测可用 IP 并推送一次。

.EXAMPLE
    powershell -File 工具\github-push.ps1 -Persist
    探测后固化到本仓库配置，以后 `git push` 直接可用。

.EXAMPLE
    powershell -File 工具\github-push.ps1 -Clear
    清除固化配置（等 DNS 恢复后建议执行）。
#>
[CmdletBinding()]
param(
    [string]$Remote = 'origin',
    [string]$Branch = '',
    [switch]$Persist,
    [switch]$Clear
)

$ErrorActionPreference = 'Stop'

# ── 候选 IP：GitHub 常用的几个边缘节点 ────────────────────────────────────────
# 这些是 github.com 的公开 IP 段，不是秘密；写多个是为了某一个被墙时有备选。
$CandidateIPs = @(
    '140.82.112.3',
    '140.82.113.3',
    '140.82.114.3',
    '140.82.121.3',
    '140.82.116.3',
    '20.205.243.168'
)

function Write-Step  { param([string]$m) Write-Host "▸ $m" -ForegroundColor Cyan }
function Write-Ok    { param([string]$m) Write-Host "  ✅ $m" -ForegroundColor Green }
function Write-Bad   { param([string]$m) Write-Host "  ✗ $m"  -ForegroundColor DarkGray }
function Write-Warn2 { param([string]$m) Write-Host "  ⚠ $m"  -ForegroundColor Yellow }

# ── 定位仓库根目录（脚本可能从任意目录被调用）────────────────────────────────
$repoRoot = git rev-parse --show-toplevel 2>$null
if ($LASTEXITCODE -ne 0 -or -not $repoRoot) {
    Write-Host "错误：当前目录不在 git 仓库里。" -ForegroundColor Red
    Write-Host "请先 cd 到仓库目录，例如： cd `"C:\Users\嘎嘎在这里\Desktop\java全栈`""
    exit 1
}
Push-Location $repoRoot
try {

    # ── -Clear：清除固化配置 ─────────────────────────────────────────────────
    if ($Clear) {
        $existing = git config --local --get http.curloptResolve 2>$null
        if ($existing) {
            git config --local --unset http.curloptResolve
            Write-Ok "已清除 http.curloptResolve（原值：$existing）"
            Write-Host "  之后将使用系统 DNS 解析。若推送再次失败，重新运行本脚本即可。"
        } else {
            Write-Host "本仓库没有配置 http.curloptResolve，无需清除。"
        }
        exit 0
    }

    # ── 取远程地址 ───────────────────────────────────────────────────────────
    $remoteUrl = git remote get-url $Remote 2>$null
    if ($LASTEXITCODE -ne 0 -or -not $remoteUrl) {
        Write-Host "错误：找不到远程 `"$Remote`"。" -ForegroundColor Red
        Write-Host "现有远程："
        git remote -v
        exit 1
    }
    if (-not $Branch) { $Branch = git rev-parse --abbrev-ref HEAD }

    Write-Host ''
    Write-Host "仓库  : $repoRoot"
    Write-Host "远程  : $Remote -> $remoteUrl"
    Write-Host "分支  : $Branch"
    Write-Host ''

    # ── 先试一次直连（DNS 正常时就不用折腾）──────────────────────────────────
    # 注意：若仓库已固化 http.curloptResolve，下面的命令会走固定 IP 而非真实 DNS，
    #       此时"直连测试"没有意义，直接跳过并说明。
    $alreadyPinned = git config --local --get http.curloptResolve 2>$null
    if ($alreadyPinned) {
        Write-Warn2 "本仓库已固化 http.curloptResolve = $alreadyPinned"
        Write-Host '  跳过直连测试（该配置会覆盖系统 DNS）。想测真实直连请先运行：'
        Write-Host '    powershell -File 工具\github-push.ps1 -Clear'
        Write-Host ''
    } else {
        Write-Step '先测试直连（系统 DNS）…'
        git ls-remote --exit-code $remoteUrl HEAD *> $null
        if ($LASTEXITCODE -eq 0) {
            Write-Ok '直连可用，DNS 目前是正常的。'
            Write-Step '执行推送…'
            git push $Remote $Branch
            if ($LASTEXITCODE -eq 0) { Write-Ok '推送成功'; exit 0 }
            Write-Warn2 '直连能读但推送失败，继续尝试固定 IP…'
        } else {
            Write-Bad '直连失败（典型症状：Connection was reset / Failed to connect）'
            Write-Host '  开始探测可用 IP…'
        }
    }

    # ── 逐个 IP 做真实应用层测试 ─────────────────────────────────────────────
    Write-Host ''
    $goodIP = $null
    foreach ($ip in $CandidateIPs) {
        Write-Host ("  测试 {0,-18}" -f $ip) -NoNewline
        git -c "http.curloptResolve=github.com:443:$ip" ls-remote --exit-code $remoteUrl HEAD *> $null
        if ($LASTEXITCODE -eq 0) {
            Write-Host ' ✅ 可用' -ForegroundColor Green
            $goodIP = $ip
            break
        } else {
            Write-Host ' ✗' -ForegroundColor DarkGray
        }
    }

    if (-not $goodIP) {
        Write-Host ''
        Write-Host '所有候选 IP 都不可用。可能原因与对策：' -ForegroundColor Red
        Write-Host '  1) 本次是真正的 SNI / 出口阻断（换 IP 无效）→ 用代理：'
        Write-Host '     git config --global http.https://github.com.proxy http://127.0.0.1:7890'
        Write-Host '  2) 想彻底摆脱这类问题 → 配 SSH over 443：'
        Write-Host '     Get-Content "$env:USERPROFILE\.ssh\id_ed25519.pub" | Set-Clipboard'
        Write-Host '     粘到 https://github.com/settings/ssh/new，然后 ssh -T -p 443 git@ssh.github.com'
        Write-Host '  3) 详细排查流程见 笔记\00-工具与环境\GitHub-推送失败排查手册.md'
        exit 1
    }

    # ── 用可用 IP 推送 ───────────────────────────────────────────────────────
    Write-Host ''
    Write-Step "用 IP $goodIP 推送…"
    git -c "http.curloptResolve=github.com:443:$goodIP" push $Remote $Branch
    if ($LASTEXITCODE -ne 0) {
        Write-Host '推送失败（读取正常但写入失败）。' -ForegroundColor Red
        Write-Host '常见原因：凭据失效 → 检查 PAT / 执行 ssh -T -p 443 git@ssh.github.com'
        exit 1
    }
    Write-Ok '推送成功'

    # ── 可选：固化 ───────────────────────────────────────────────────────────
    if ($Persist) {
        git config --local http.curloptResolve "github.com:443:$goodIP"
        Write-Host ''
        Write-Ok "已固化到本仓库配置：http.curloptResolve = github.com:443:$goodIP"
        Write-Host '  以后直接 `git push` 即可，无需再运行本脚本。'
        Write-Host '  ⚠ IP 会过期。若某天又失败，重新运行本脚本，或用 -Clear 清除后走直连。'
    } else {
        Write-Host ''
        Write-Host '提示：加 -Persist 参数可把该 IP 固化到本仓库配置，之后 `git push` 直接可用。'
        Write-Host '      git push 现在失败的话，运行： powershell -File 工具\github-push.ps1 -Persist'
    }

} finally {
    Pop-Location
}
