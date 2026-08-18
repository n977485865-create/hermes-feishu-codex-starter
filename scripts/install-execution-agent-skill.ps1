# 将当前完整 Skill 安装到 Windows 已检测到的执行 Agent 用户级或项目级目录。
# 不安装、不修改 Hermes Gateway、飞书机器人、Profile 或任何凭证。
[CmdletBinding()]
param(
    [ValidateSet('auto', 'all', 'codex', 'claude', 'workbuddy', 'traework', 'trae')]
    [string]$Target = 'auto',

    [ValidateSet('user', 'project')]
    [string]$Scope = 'user',

    [switch]$DryRun,
    [switch]$Replace
)

$ErrorActionPreference = 'Stop'
$SkillName = 'hermes-feishu-codex-starter'
$SourceDir = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path

if ($Scope -eq 'project' -and -not (Test-Path (Join-Path (Get-Location) '.git'))) {
    throw '项目级安装必须从 Git 项目根目录运行。'
}

function Test-CommandExists {
    param([string]$Name)
    return $null -ne (Get-Command $Name -ErrorAction SilentlyContinue)
}

function Test-AgentDetected {
    param([string]$Agent)
    switch ($Agent) {
        'codex' { return Test-CommandExists 'codex' }
        'claude' { return Test-CommandExists 'claude' }
        'workbuddy' {
            return (Test-CommandExists 'workbuddy') -or
                (Test-CommandExists 'codebuddy') -or
                (Test-Path (Join-Path $env:LOCALAPPDATA 'Programs\WorkBuddy')) -or
                (Test-Path (Join-Path $env:APPDATA 'WorkBuddy'))
        }
        'traework' {
            return (Test-Path (Join-Path $HOME '.trae-cn')) -or
                (Test-Path (Join-Path $env:LOCALAPPDATA 'Programs\TraeWork')) -or
                (Test-Path (Join-Path $env:APPDATA 'TraeWork'))
        }
        'trae' {
            return (Test-CommandExists 'trae') -or
                (Test-Path (Join-Path $HOME '.trae')) -or
                (Test-Path (Join-Path $env:LOCALAPPDATA 'Programs\Trae'))
        }
    }
}

function Get-SkillBaseDirectory {
    param([string]$Agent)
    if ($Scope -eq 'project') {
        switch ($Agent) {
            'codex' { return (Join-Path (Get-Location) '.agents\skills') }
            'claude' { return (Join-Path (Get-Location) '.claude\skills') }
            'workbuddy' { return (Join-Path (Get-Location) '.codebuddy\skills') }
            'traework' { return (Join-Path (Get-Location) '.trae\skills') }
            'trae' { return (Join-Path (Get-Location) '.trae\skills') }
        }
    }

    switch ($Agent) {
        'codex' { return (Join-Path $HOME '.agents\skills') }
        'claude' { return (Join-Path $HOME '.claude\skills') }
        'workbuddy' { return (Join-Path $HOME '.codebuddy\skills') }
        'traework' { return (Join-Path $HOME '.trae-cn\skills') }
        'trae' { return (Join-Path $HOME '.trae\skills') }
    }
}

function Install-Skill {
    param([string]$Agent)

    $BaseDirectory = Get-SkillBaseDirectory $Agent
    $Destination = Join-Path $BaseDirectory $SkillName

    if ($DryRun) {
        Write-Output "[预演] $Agent -> $Destination"
        return
    }

    if (Test-Path $Destination) {
        $ResolvedDestination = (Resolve-Path $Destination).Path
        if ($ResolvedDestination.TrimEnd('\') -ieq $SourceDir.TrimEnd('\')) {
            Write-Output "[跳过] $Agent：当前目录已是安装目录"
            return
        }
        if (-not $Replace) {
            throw "目标已存在且不会被静默覆盖：$Destination。确认替换后重新执行并加 -Replace。"
        }
        Remove-Item -LiteralPath $Destination -Recurse -Force
    }

    New-Item -ItemType Directory -Force -Path $BaseDirectory | Out-Null
    Copy-Item -LiteralPath $SourceDir -Destination $Destination -Recurse -Force
    Write-Output "[完成] $Agent -> $Destination"
}

$Agents = @('codex', 'claude', 'workbuddy', 'traework', 'trae')
if ($Target -eq 'auto') {
    $Selected = @($Agents | Where-Object { Test-AgentDetected $_ })
} elseif ($Target -eq 'all') {
    $Selected = $Agents
} else {
    $Selected = @($Target)
}

if ($Selected.Count -eq 0) {
    throw '未识别到受支持的执行 Agent。可用 -Target 指定：codex、claude、workbuddy、traework 或 trae。'
}

Write-Output "Hermes + 飞书底座不会被此脚本修改。安装范围：$Scope"
foreach ($Agent in $Selected) {
    Install-Skill $Agent
}

if ($DryRun) {
    Write-Output '预演完成；移除 -DryRun 后执行实际复制。'
} else {
    Write-Output "安装完成。重启对应执行 Agent 或新开会话后加载 $SkillName。"
}
