# autoconfigs

一系列用于自动配置开发环境的脚本和配置文件，同时支持 Linux 和 Windows 系统。

## 📁 目录结构

```plaintext
autoconfigs/
├── common/             # 通用配置文件
│   └── gitconfig      # Git 配置文件
├── Linux/             # Linux 系统配置脚本
│   └── install_omb.sh # Oh My Bash 自动安装脚本
└── Windows/           # Windows 系统配置脚本
    └── install_omp.ps1 # Oh My Posh 自动安装脚本
```

---

## 📦 模块说明

### Linux 系统配置

#### `Linux/install_omb.sh`

自动安装和配置 [Oh My Bash](https://github.com/ohmybash/oh-my-bash) 的 Bash 脚本，功能包括：

- ✨ **自动安装** Oh My Bash（如未安装）
- 🐍 **Python 虚拟环境显示**：启用 `OMB_PROMPT_SHOW_PYTHON_VENV`
- 🐼 **Conda 集成**：自动初始化 Conda（如已安装）
- 🎨 **自定义主题**：创建 `sexy_custom` 主题，在用户名后随机插入 Emoji
- 💫 **随机表情**：包含 100+ 个精选 Emoji，让你的终端提示符更有趣

**效果预览：**

```bash
username ✅ at hostname in ~
username 🫛 at hostname in ~/projects
username 🚀 at hostname in ~/code
```

### Windows 系统配置

#### `Windows/install_omp.ps1`

自动安装和配置 [Oh My Posh](https://ohmyposh.dev/) 的 PowerShell 脚本，功能包括：

- 🔧 **PowerShell 7**：安装最新版 PowerShell 7
- 🎯 **Oh My Posh**：安装并配置 Oh My Posh
- 📦 **实用模块**：自动安装 Terminal-Icons、posh-git、ZLocation2
- 🔤 **Nerd Font**：安装 Meslo LGM Nerd Font 字体
- ⚙️ **终端配置**：自动配置 Windows Terminal 默认设置
- 🎨 **主题选择**：支持选择不同的 Oh My Posh 主题

**支持的模块：**

- `Terminal-Icons`：文件类型图标显示
- `posh-git`：Git 状态显示
- `ZLocation2`：智能目录跳转

### 通用配置

#### `common/gitconfig`

通用的 Git 配置文件，包含常用设置和别名：

**功能特性：**

- 🎨 **彩色输出**：启用 Git 命令的彩色显示
- ⚡ **实用别名**：预设常用的 Git 命令别名
- 📝 **编辑器配置**：默认使用 vim 作为编辑器
- 🔧 **跨平台兼容**：适配不同操作系统的换行符处理

**内置别名：**

```bash
git st      # git status
git ci      # git commit  
git co      # git checkout
git br      # git branch
git lg      # git log --oneline --graph --decorate --all
git last    # git log -1 HEAD
git unstage # git reset HEAD --
```

**使用方式：**

```bash
# 直接下载配置文件
curl -fsSL https://raw.githubusercontent.com/hellototoro/autoconfigs/main/common/gitconfig -o ~/.gitconfig
```

---

## 🚀 使用指南

### 配置 Git

```bash
# 下载 Git 配置文件
curl -O https://raw.githubusercontent.com/hellototoro/autoconfigs/main/common/gitconfig

# 方法 1：复制配置文件
# Linux
cp gitconfig ~/.gitconfig
# Windows
Copy-Item common\gitconfig $env:USERPROFILE\.gitconfig

# 方法 2：直接下载到目标位置（推荐）
curl -fsSL https://raw.githubusercontent.com/hellototoro/autoconfigs/main/common/gitconfig -o ~/.gitconfig

# 记得修改用户信息
git config --global user.name "你的姓名"
git config --global user.email "你的邮箱"
```

### Linux 系统

#### 安装 Oh My Bash

```bash
# 直接下载并运行安装脚本
curl -fsSL https://raw.githubusercontent.com/hellototoro/autoconfigs/main/Linux/install_omb.sh | bash

# 使配置生效
source ~/.bashrc
```

**或者手动下载后执行：**

```bash
# 下载脚本
curl -O https://raw.githubusercontent.com/hellototoro/autoconfigs/main/Linux/install_omb.sh

# 添加执行权限并运行
chmod +x install_omb.sh
./install_omb.sh

# 使配置生效
source ~/.bashrc
```

### Windows 系统

#### 安装 Oh My Posh

1. **以管理员身份运行 PowerShell**
2. **执行安装脚本**：

```powershell
# 克隆项目
git clone https://github.com/hellototoro/autoconfigs.git
cd autoconfigs

# 允许执行脚本（如果需要）
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser

# 运行 Windows 配置脚本
.\Windows\install_omp.ps1
```

3. **手动设置 VSCode 字体**：
   - 打开 VSCode 设置
   - 搜索 `terminal.integrated.fontFamily`
   - 设置为：`MesloLGM Nerd Font`

---

## ⚠️ 注意事项

- **Linux**：脚本会自动备份原有配置文件
- **Windows**：需要管理员权限运行 PowerShell 脚本
- **字体**：确保终端使用 Nerd Font 字体以正确显示图标
- **主题**：可以根据个人喜好修改 Oh My Bash/Posh 主题

---

## 🔧 故障排除

### Linux 常见问题

**Q: 脚本下载失败？**

```bash
# 检查网络连接，或使用代理
curl --proxy http://proxy:port -fsSL https://raw.githubusercontent.com/hellototoro/autoconfigs/main/Linux/install_omb.sh | bash
```

**Q: Oh My Bash 安装失败？**

```bash
# 手动安装
bash -c "$(curl -fsSL https://raw.githubusercontent.com/ohmybash/oh-my-bash/master/tools/install.sh)"
```

**Q: 主题不生效？**

```bash
# 重新加载配置
source ~/.bashrc

# 或重启终端
```

### Windows 常见问题

**Q: 执行策略阻止脚本运行？**

```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

**Q: 字体显示异常？**

- 确保安装了 Nerd Font
- 检查终端字体设置
- 重启终端应用

---

## 🤝 贡献

欢迎提交 Issue 和 Pull Request 来改进这个项目！

## 📄 许可证

本项目采用 MIT 许可证。

---

## 🙏 致谢

- [Oh My Bash](https://github.com/ohmybash/oh-my-bash) - Linux 终端美化
- [Oh My Posh](https://ohmyposh.dev/) - Windows PowerShell 美化
- [Nerd Fonts](https://nerdfonts.com/) - 编程字体
