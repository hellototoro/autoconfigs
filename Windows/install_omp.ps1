# 安装最新版 PowerShell 7
winget install --id Microsoft.PowerShell --source winget

# 检查并安装 OhMyPosh
Write-Host "正在检查 OhMyPosh 安装状态..."
$ohMyPoshInstalled = winget list JanDeDobbeleer.OhMyPosh 2>$null
if ($LASTEXITCODE -eq 0 -and $ohMyPoshInstalled -match "JanDeDobbeleer.OhMyPosh") {
    Write-Host "检测到 OhMyPosh 已安装，正在卸载旧版本..."
    winget uninstall JanDeDobbeleer.OhMyPosh
    Write-Host "旧版本已卸载，正在安装最新版本..."
} else {
    Write-Host "OhMyPosh 未安装，正在安装..."
}
winget install JanDeDobbeleer.OhMyPosh

# 安装/更新 Terminal-Icons、posh-git、ZLocation2 模块
$modules = @('Terminal-Icons', 'posh-git', 'ZLocation2')
foreach ($moduleName in $modules) {
    Write-Host "正在检查模块: $moduleName"
    
    # 检查模块是否已安装
    $installedModule = Get-Module -ListAvailable -Name $moduleName
    
    if ($installedModule) {
        Write-Host "模块 $moduleName 已安装，版本: $($installedModule.Version)"
        
        # 检查模块是否正在运行
        $runningModule = Get-Module -Name $moduleName
        if ($runningModule) {
            Write-Host "模块 $moduleName 正在运行，正在停止..."
            Remove-Module -Name $moduleName -Force
        }
        
        Write-Host "正在更新模块 $moduleName..."
        Update-Module -Name $moduleName -Scope CurrentUser -Force
    } else {
        Write-Host "模块 $moduleName 未安装，正在安装..."
        Install-Module -Name $moduleName -Scope CurrentUser -Force
    }
}

# 安装 Meslo 字体
oh-my-posh font install meslo

# 设置 Windows Terminal 默认终端为 PowerShell 7
$settingsPath = "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json"
if (Test-Path $settingsPath) {
    Write-Host "正在配置 Windows Terminal 设置..." -ForegroundColor Yellow
    
    try {
        $settings = Get-Content $settingsPath -Raw | ConvertFrom-Json
        
        # 查找 PowerShell 7 配置文件
        $pwshProfile = $settings.profiles.list | Where-Object { 
            $_.name -like "*PowerShell*" -and ($_.commandline -like "*pwsh*" -or $_.source -eq "Windows.Terminal.PowershellCore")
        }
        
        if ($pwshProfile) {
            Write-Host "找到 PowerShell 7 配置文件: $($pwshProfile.name)" -ForegroundColor Green
            
            # 设置默认配置文件为 PowerShell 7
            $settings.defaultProfile = $pwshProfile.guid
            Write-Host "已设置默认终端为 PowerShell 7 (GUID: $($pwshProfile.guid))" -ForegroundColor Green
            
            # 确保 profiles.defaults 存在
            if (-not $settings.profiles.defaults) {
                $settings.profiles | Add-Member -MemberType NoteProperty -Name "defaults" -Value @{} -Force
            }
            
            # 设置默认字体
            if (-not $settings.profiles.defaults.font) {
                $settings.profiles.defaults | Add-Member -MemberType NoteProperty -Name "font" -Value @{} -Force
            }
            $settings.profiles.defaults.font | Add-Member -MemberType NoteProperty -Name "face" -Value "MesloLGM Nerd Font" -Force
            Write-Host "已设置默认字体为 MesloLGM Nerd Font" -ForegroundColor Green
            
            # 保存设置
            $settings | ConvertTo-Json -Depth 100 | Set-Content $settingsPath -Encoding UTF8
            Write-Host "Windows Terminal 配置已更新" -ForegroundColor Green
        } else {
            Write-Host "未找到 PowerShell 7 配置文件，请确保已安装 PowerShell 7" -ForegroundColor Red
            Write-Host "可用的配置文件:" -ForegroundColor Yellow
            $settings.profiles.list | ForEach-Object { 
                Write-Host "  - $($_.name) (GUID: $($_.guid))" -ForegroundColor White
            }
        }
    } catch {
        Write-Host "配置 Windows Terminal 时出错: $($_.Exception.Message)" -ForegroundColor Red
    }
} else {
    Write-Host "Windows Terminal 设置文件不存在: $settingsPath" -ForegroundColor Red
    Write-Host "请确保已安装 Windows Terminal" -ForegroundColor Yellow
}

# 提示用户手动设置 VSCode 终端字体
Write-Host "`n请将 VSCode 的 terminal.integrated.fontFamily 设置为: MesloLGM Nerd Font`n"

# 设置 PowerShell 7 的 prompt 和导入模块
if ((Test-Path $PROFILE)) {
    # 如果配置文件已存在，先备份，再删除
    $backupPath = "$PROFILE.bak"
    Copy-Item -Path $PROFILE -Destination $backupPath -Force
    Remove-Item -Path $PROFILE -Force
}

New-Item -Path $PROFILE -Type File -Force | Out-Null

# 列出可用主题
Write-Host "`n可用的 OhMyPosh 主题:" -ForegroundColor Cyan
Write-Host "========================" -ForegroundColor Cyan

try {
    # 获取主题目录路径
    $themesPath = $env:POSH_THEMES_PATH
    if (-not $themesPath -or -not (Test-Path $themesPath)) {
        # 尝试通过 oh-my-posh 命令获取主题路径
        $envOutput = oh-my-posh get shell
        if ($env:POSH_THEMES_PATH) {
            $themesPath = $env:POSH_THEMES_PATH
        } else {
            # 默认主题路径
            $themesPath = "$env:LOCALAPPDATA\Programs\oh-my-posh\themes"
        }
    }
    
    if (Test-Path $themesPath) {
        $themeFiles = Get-ChildItem -Path $themesPath -Filter "*.omp.json" | Sort-Object Name
        $counter = 1
        $themeList = @()
        
        foreach ($themeFile in $themeFiles) {
            $themeName = $themeFile.BaseName
            $themeList += $themeName
            Write-Host "[$counter] $themeName" -ForegroundColor Yellow
            $counter++
        }
        
        Write-Host "`n推荐主题:" -ForegroundColor Green
        Write-Host "- jandedobbeleer (默认)" -ForegroundColor Green
        Write-Host "- powerline (经典)" -ForegroundColor Green
        Write-Host "- agnoster (流行)" -ForegroundColor Green
        Write-Host "- paradox (简洁)" -ForegroundColor Green
        
        Write-Host "`n您可以:" -ForegroundColor Cyan
        Write-Host "1. 输入主题名称 (如: jandedobbeleer)" -ForegroundColor White
        Write-Host "2. 输入主题编号 (如: 1)" -ForegroundColor White
        Write-Host "3. 直接按回车使用默认主题 (jandedobbeleer)" -ForegroundColor White
        
        $userInput = Read-Host "`n请选择主题"
        
        if ([string]::IsNullOrWhiteSpace($userInput)) {
            $theme = "jandedobbeleer"
        } elseif ($userInput -match '^\d+$') {
            # 用户输入的是数字
            $index = [int]$userInput - 1
            if ($index -ge 0 -and $index -lt $themeList.Count) {
                $theme = $themeList[$index]
            } else {
                Write-Host "无效的编号，使用默认主题" -ForegroundColor Yellow
                $theme = "jandedobbeleer"
            }
        } else {
            # 用户输入的是主题名称
            $theme = $userInput
        }
    } else {
        Write-Host "无法找到主题目录，使用默认主题" -ForegroundColor Yellow
        $theme = Read-Host "请输入 OhMyPosh 主题名称 (如 jandedobbeleer, powerline)"
        if ([string]::IsNullOrWhiteSpace($theme)) { $theme = "jandedobbeleer" }
    }
} catch {
    Write-Host "列出主题时出错: $($_.Exception.Message)" -ForegroundColor Red
    $theme = Read-Host "请输入 OhMyPosh 主题名称 (如 jandedobbeleer, powerline)"
    if ([string]::IsNullOrWhiteSpace($theme)) { $theme = "jandedobbeleer" }
}

# 如果用户输入的不是 .omp.json 结尾，自动添加后缀
if (-not $theme.EndsWith(".omp.json")) {
    if ($theme.EndsWith(".omp")) {
        # 如果用户输入的是 .omp，自动添加 .json 后缀
        $theme = "$theme.json"
    } else {
        # 否则直接添加 .omp.json 后缀
        $theme = "$theme.omp.json"
    }
}

Write-Host "`n选择的主题: $theme" -ForegroundColor Green

Add-Content $PROFILE @"
oh-my-posh init pwsh --config `"`$env:POSH_THEMES_PATH\$theme`" | Invoke-Expression
Import-Module Terminal-Icons
Import-Module posh-git
Import-Module ZLocation2
"@
Write-Host "`n已完成配置，请重启 PowerShell 7 或 Windows Terminal。"
