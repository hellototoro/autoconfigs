
# 检查 PowerShell 7 是否已安装
if (-not (Get-Command pwsh -ErrorAction SilentlyContinue)) {
    Write-Host "PowerShell 7 未安装，正在尝试安装..." -ForegroundColor Yellow
    try {
        winget install Microsoft.PowerShell -s winget
        Write-Host "PowerShell 7 安装完成！" -ForegroundColor Green
        Write-Host "请重启终端并使用 PowerShell 7 (pwsh) 运行此脚本" -ForegroundColor Yellow
        Write-Host "您可以在 Windows Terminal 中选择 'PowerShell' 配置文件" -ForegroundColor Cyan
        exit
    } catch {
        Write-Host "自动安装失败，请手动安装 PowerShell 7: winget install Microsoft.PowerShell" -ForegroundColor Red
        Write-Host "或访问: https://github.com/PowerShell/PowerShell/releases" -ForegroundColor Cyan
        exit
    }
}

Write-Host "检测到 PowerShell 7 已安装，版本: $((Get-Command pwsh).Version)" -ForegroundColor Green

# 检查 oh-my-posh 是否已安装
if (-not (Get-Command oh-my-posh -ErrorAction SilentlyContinue)) {
    Write-Host "oh-my-posh 未安装，正在尝试安装..." -ForegroundColor Yellow
    try {
        winget install JanDeDobbeleer.OhMyPosh -s winget
        Write-Host "oh-my-posh 安装完成，请重启终端后再次运行此脚本" -ForegroundColor Green
        exit
    } catch {
        Write-Host "自动安装失败，请手动安装 oh-my-posh: winget install JanDeDobbeleer.OhMyPosh" -ForegroundColor Red
        exit
    }
}

Write-Host "检测到 oh-my-posh 已安装" -ForegroundColor Green

# 安装/更新 Terminal-Icons、posh-git、ZLocation2 模块
$modules = @('Terminal-Icons', 'posh-git', 'ZLocation2')
foreach ($moduleName in $modules) {
    Write-Host "正在检查模块: $moduleName"

    # 检查模块是否已安装
    $installedModule = Get-Module -ListAvailable -Name $moduleName

    if ($installedModule) {
        Write-Host "模块 $moduleName 已安装，版本: $($installedModule.Version)" -ForegroundColor Green

        # 检查模块是否正在运行
        $runningModule = Get-Module -Name $moduleName
        if ($runningModule) {
            Write-Host "模块 $moduleName 正在运行，正在停止..."
            Remove-Module -Name $moduleName -Force
        }

        try {
            Write-Host "正在检查模块 $moduleName 是否有更新..."
            Update-Module -Name $moduleName -Scope CurrentUser -Force -ErrorAction Stop
            Write-Host "模块 $moduleName 更新检查完成" -ForegroundColor Green
        } catch {
            Write-Host "模块 $moduleName 无需更新或更新失败（这通常不影响使用）" -ForegroundColor Yellow
        }
    } else {
        Write-Host "模块 $moduleName 未安装，正在安装..."
        Install-Module -Name $moduleName -Scope CurrentUser -Force
        Write-Host "模块 $moduleName 安装完成" -ForegroundColor Green
    }
}


# 设置 Windows Terminal 默认终端为 PowerShell 7
$settingsPath = "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json"
if (Test-Path $settingsPath) {
    Write-Host "正在检查 Windows Terminal 设置..." -ForegroundColor Yellow

    try {
        $settings = Get-Content $settingsPath -Raw | ConvertFrom-Json

        # 查找 PowerShell 7 配置文件
        $pwshProfile = $settings.profiles.list | Where-Object {
            $_.name -like "*PowerShell*" -and ($_.commandline -like "*pwsh*" -or $_.source -eq "Windows.Terminal.PowershellCore")
        }

        if ($pwshProfile) {
            $needsUpdate = $false

            # 检查是否需要更新默认配置文件
            if ($settings.defaultProfile -ne $pwshProfile.guid) {
                $settings.defaultProfile = $pwshProfile.guid
                $needsUpdate = $true
                Write-Host "已设置默认终端为 PowerShell 7 (GUID: $($pwshProfile.guid))" -ForegroundColor Green
            } else {
                Write-Host "默认终端已经是 PowerShell 7" -ForegroundColor Green
            }

            # 确保 profiles.defaults 存在
            if (-not $settings.profiles.defaults) {
                $settings.profiles | Add-Member -MemberType NoteProperty -Name "defaults" -Value @{} -Force
            }

            # 检查是否需要设置默认字体
            if (-not $settings.profiles.defaults.font) {
                $settings.profiles.defaults | Add-Member -MemberType NoteProperty -Name "font" -Value @{} -Force
            }
            if ($settings.profiles.defaults.font.face -ne "MesloLGM Nerd Font") {
                $settings.profiles.defaults.font | Add-Member -MemberType NoteProperty -Name "face" -Value "MesloLGM Nerd Font" -Force
                $needsUpdate = $true
                Write-Host "已设置默认字体为 MesloLGM Nerd Font" -ForegroundColor Green
            } else {
                Write-Host "默认字体已经是 MesloLGM Nerd Font" -ForegroundColor Green
            }

            # 仅在需要时保存设置
            if ($needsUpdate) {
                $settings | ConvertTo-Json -Depth 100 | Set-Content $settingsPath -Encoding UTF8
                Write-Host "Windows Terminal 配置已更新" -ForegroundColor Green
            } else {
                Write-Host "Windows Terminal 配置无需更新" -ForegroundColor Cyan
            }
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

# 提示用户手动设置字体
Write-Host "`n===================" -ForegroundColor Yellow
Write-Host "字体配置提醒" -ForegroundColor Yellow
Write-Host "===================" -ForegroundColor Yellow
Write-Host "请确保已安装 Nerd Font 字体（如 MesloLGM Nerd Font）" -ForegroundColor Cyan
Write-Host "下载地址: https://www.nerdfonts.com/font-downloads" -ForegroundColor Cyan
Write-Host "`n配置方法:" -ForegroundColor White
Write-Host "1. VSCode: 设置 terminal.integrated.fontFamily 为 'MesloLGM Nerd Font'" -ForegroundColor White
Write-Host "2. Windows Terminal: 在设置中已自动配置为 'MesloLGM Nerd Font'`n" -ForegroundColor White

# 设置 PowerShell 7 的 prompt 和导入模块
$configToAdd = @"
oh-my-posh init pwsh | Invoke-Expression
Import-Module Terminal-Icons
Import-Module posh-git
Import-Module ZLocation2

Set-PSReadLineKeyHandler -Key UpArrow -Function HistorySearchBackward       # 设置向上键为后向搜索历史记录
Set-PSReadLineKeyHandler -Key DownArrow -Function HistorySearchForward      # 设置向下键为前向搜索历史纪录
Set-PSReadlineKeyHandler -Key Tab -Function Complete                        # 设置 Tab 键补全
Set-PSReadLineKeyHandler -Key "Ctrl+d" -Function MenuComplete               # 设置 Ctrl+d 为菜单补全和 Intellisense
"@

# 检查配置文件是否已存在
$needsProfileUpdate = $false
$profileExists = Test-Path $PROFILE

if ($profileExists) {
    # 如果配置文件已存在，检查是否已有 oh-my-posh 配置
    $profileContent = Get-Content $PROFILE -Raw -ErrorAction SilentlyContinue

    if ($profileContent -match 'oh-my-posh') {
        Write-Host "检测到 PowerShell 配置文件中已有 oh-my-posh 配置" -ForegroundColor Green
        Write-Host "配置文件路径: $PROFILE" -ForegroundColor Cyan

        $response = Read-Host "是否要重新配置？(y=覆盖配置/s=跳过配置/N=退出) [N]"

        if ($response -eq 'y' -or $response -eq 'Y') {
            $timestamp = Get-Date -Format 'yyyyMMdd_HHmmss'
            $backupPath = $PROFILE + '.backup_' + $timestamp
            Copy-Item -Path $PROFILE -Destination $backupPath -Force
            Write-Host "已备份原配置文件到: $backupPath" -ForegroundColor Green
            Remove-Item -Path $PROFILE -Force
            New-Item -Path $PROFILE -Type File -Force | Out-Null
            $needsProfileUpdate = $true
        } elseif ($response -eq 's' -or $response -eq 'S') {
            Write-Host "跳过配置文件更新，使用现有配置" -ForegroundColor Yellow
            Write-Host "`n===========================" -ForegroundColor Green
            Write-Host "脚本执行完成！" -ForegroundColor Green
            Write-Host "===========================" -ForegroundColor Green
            Write-Host "现有配置文件位置: $PROFILE" -ForegroundColor Cyan
            exit
        } else {
            Write-Host "已退出脚本" -ForegroundColor Yellow
            exit
        }
    } else {
        # 没有 oh-my-posh 配置，追加到文件末尾
        Write-Host "将在现有配置文件末尾追加 oh-my-posh 配置" -ForegroundColor Green
        $needsProfileUpdate = $true
    }
} else {
    # 配置文件不存在，创建新文件
    New-Item -Path $PROFILE -Type File -Force | Out-Null
    Write-Host "已创建新的 PowerShell 配置文件" -ForegroundColor Green
    $needsProfileUpdate = $true
}

# 仅在需要时写入配置
if ($needsProfileUpdate) {
    # 写入配置
    Add-Content $PROFILE $configToAdd

    Write-Host "`n============================" -ForegroundColor Green
    Write-Host "配置完成！" -ForegroundColor Green
    Write-Host "============================" -ForegroundColor Green
    Write-Host "请执行以下操作之一使配置生效:" -ForegroundColor Yellow
    Write-Host "1. 重启 PowerShell 7 或 Windows Terminal" -ForegroundColor White
    Write-Host "2. 在当前会话中运行: . `$PROFILE" -ForegroundColor White
    Write-Host "`n配置文件位置: $PROFILE" -ForegroundColor Cyan
} else {
    Write-Host "`n============================" -ForegroundColor Green
    Write-Host "脚本执行完成！" -ForegroundColor Green
    Write-Host "============================" -ForegroundColor Green
    Write-Host "配置文件未修改" -ForegroundColor Yellow
}
