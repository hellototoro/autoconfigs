# autoconfigs

一系列用于自动配置开发环境的 Bash 脚本和配置文件，适用于 Linux 系统。

## 📁 目录结构

autoconfigs/
├── common/ # 通用配置（如 gitconfig）
│ └── gitconfig
├── linux/ # Linux 系统下的自动安装脚本
│ └── install_omb.sh

---

## 📦 模块说明

### `linux/install_omb.sh`

自动安装和配置 [Oh My Bash](https://github.com/ohmybash/oh-my-bash)，功能包括：

- 安装 Oh My Bash（如未安装）
- 启用虚拟环境显示：`OMB_PROMPT_SHOW_PYTHON_VENV`
- 自动初始化 Conda（如已安装）
- 创建自定义主题 `sexy_custom`，在用户名后随机插入 Emoji
- 你的提示符会变成这样：`totoro ✅ at zk in ~` or `totoro 🫛 at zk in ~`

### `common/gitconfig`

通用的 Git 配置文件，可复制或软链接至 `~/.gitconfig`，包含常用 alias、颜色与基本用户信息。

```bash
cp common/gitconfig ~/.gitconfig
# or
ln -s $(pwd)/common/gitconfig ~/.gitconfig
```

---

## 🚀 使用指南

### 安装 Oh My Bash

```bash
cd linuxconfigs
chmod +x install_omb.sh
./install_omb.sh
```
