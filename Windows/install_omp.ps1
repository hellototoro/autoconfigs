# 安装最新版 PowerShell 7
winget install --id Microsoft.PowerShell --source winget

# 安装 OhMyPosh
winget install JanDeDobbeleer.OhMyPosh

# 安装 Terminal-Icons、posh-git、ZLocation2 模块
Install-Module -Name Terminal-Icons -Scope CurrentUser -Force
Install-Module -Name posh-git -Scope CurrentUser -Force
Install-Module -Name ZLocation2 -Scope CurrentUser -Force

# 安装 Meslo 字体
oh-my-posh font install meslo

# 设置 Windows Terminal 默认终端为 PowerShell 7
$settingsPath = "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json"
if (Test-Path $settingsPath) {
    $settings = Get-Content $settingsPath -Raw | ConvertFrom-Json
    $pwshProfile = $settings.profiles.list | Where-Object { $_.name -like "*PowerShell*" -and $_.commandline -like "*pwsh*" }
    if ($pwshProfile) {
        $settings.profiles.defaults.font.face = "MesloLGM Nerd Font"
        $settings.defaultProfile = $pwshProfile.guid
        $settings | ConvertTo-Json -Depth 100 | Set-Content $settingsPath
    }
}

# 提示用户手动设置 VSCode 终端字体
Write-Host "`n请将 VSCode 的 terminal.integrated.fontFamily 设置为: MesloLGM Nerd Font`n"

# 设置 PowerShell 7 的 prompt 和导入模块
if (!(Test-Path $PROFILE)) {
    New-Item -Path $PROFILE -Type File -Force | Out-Null
}

# 选择主题
$themesPath = (oh-my-posh get themes --output json | ConvertFrom-Json)[0].path
$theme = Read-Host "请输入 OhMyPosh 主题名称 (如 powerline.omp.json)"
if ([string]::IsNullOrWhiteSpace($theme)) { $theme = "powerline.omp.json" }

Add-Content $PROFILE @"
oh-my-posh init pwsh `"$env:POSH_THEMES_PATH/$theme`" | Invoke-Expression
Import-Module Terminal-Icons
Import-Module posh-git
Import-Module ZLocation2
"@
Write-Host "`n已完成配置，请重启 PowerShell 7 或 Windows Terminal。"
