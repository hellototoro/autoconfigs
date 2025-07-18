#!/usr/bin/env bash

set -e

# ========== 1. 定义 Emoji 表情 ==========
emojis=(
"😆" "😅" "😂" "🎂" "😊" "😇" "🥳" "😎" "🤡" "🤩" "🍭" "😁"
"😘" "💕" "👍" "🙌" "😒" "😎" "🤩" "🫥" "🌫️" "🫡" "😯" "😪"
"😫" "🥱" "😴" "🤑" "😲" "🙁" "😖" "😞" "😵" "💫" "🥴" "😠"
"😷" "🤒" "🤕" "🤢" "😇" "🧐" "🤓" "👿" "🍕" "🍔" "🌽" "🍆"
"🍟" "🌭" "🍿" "🧂" "🥓" "🥚" "🍳" "🧇" "🧈" "🥡" "🍚" "🍪"
"☕" "🥛" "🥢" "🧋" "🍇" "🍈" "🍉" "🍎" "🥭" "🍍" "🍑" "🍓"
"🍅" "🌻" "🌼" "🪻" "🌿" "🚄" "🚲" "🚥" "🌍" "🌈" "🔥" "🛜"
"🤺" "🦾" "👀" "🐝" "🦂" "🦗" "🐧" "🦉" "🐓" "🐳" "🐬" "🦖"
"🐉" "🐼" "💩" "🥷" "🧗" "🏇" "🏂" "🏊" "🚴" "🚵" "🎉" "🎍"
"👑" "🏀" "🥇" "🏆" "🎮" "🎲" "🏅" "🎼" "🎹" "📻" "📶" "🧱"
"🛖" "📱" "💻" "💿" "📺" "💰" "🥒" "🫛" "🪺" "🫢" "🌶️" "😡"
"🛻" "🚀" "🏁" "🏞️" "🛣️" "🌚" "🌤️" "💢" "💯" "⛔" "✅" "🫒"
"🫐" "🫓" "🫖" "🫗" "🫙" "🫚" "🫠"
)

# ========== 2. 安装 Oh My Bash ==========
if [ ! -d "$HOME/.oh-my-bash" ]; then
  echo "🔧 Installing Oh My Bash..."
  bash -c "$(curl -fsSL https://raw.githubusercontent.com/ohmybash/oh-my-bash/master/tools/install.sh)" --unattended
    
  # 检查是否安装成功，否则退出
  if [ ! -d "$HOME/.oh-my-bash" ]; then
    echo "❌ Oh My Bash 安装失败，退出脚本。"
    exit 1
  fi

fi

# ========== 3. 启用 Python 虚拟环境提示 ==========
if ! grep -q "OMB_PROMPT_SHOW_PYTHON_VENV" ~/.bashrc; then
  echo 'export OMB_PROMPT_SHOW_PYTHON_VENV=true' >> ~/.bashrc
fi

# ========== 4. 检查 Conda 并初始化 ==========
if command -v conda &>/dev/null; then
  echo "📦 Conda detected. Running conda init --all..."
  conda init --all
fi

# ========== 5. 自定义主题 sexy_custom ==========
THEME_SRC="$HOME/.oh-my-bash/themes/sexy/sexy.theme.sh"
THEME_DST="$HOME/.oh-my-bash/custom/themes/sexy_custom/sexy_custom.theme.sh"

if [ -f "$THEME_SRC" ]; then
  echo "🎨 Creating custom theme: sexy_custom"
  mkdir -p "$(dirname "$THEME_DST")"
  cp "$THEME_SRC" "$THEME_DST"

  # Step 1: 插入 emoji 数组到文件顶部（函数外）
  emoji_line='emojis=('
  for e in "${emojis[@]}"; do
    emoji_line+="$e "
  done
  emoji_line+=')'
  sed -i "0,/^$/s||$emoji_line\n\n&|" "$THEME_DST"

  # Step 2: 在函数开头插入随机选择逻辑
  sed -i '/^function _omb_theme_PROMPT_COMMAND() {$/a\
  local emoji=${emojis[$((RANDOM % ${#emojis[@]}))]}' "$THEME_DST"

  # Step 3: 替换 PS1 行，插入 $emoji 在 \u 后、at 前
  sed -i "s|PS1=\$python_venv\$MAGENTA'\\\\u '\$WHITE'at '\$ORANGE'\\\\h'|PS1=\$python_venv\$MAGENTA'\\\\u '\$emoji' '\$WHITE'at '\$ORANGE'\\\\h'|" "$THEME_DST"

  # Step 4: 修改主题为 sexy_custom
  sed -i 's/^OSH_THEME=.*/OSH_THEME="sexy_custom"/' ~/.bashrc

else
  echo "⚠️ 原始 sexy 主题不存在，跳过自定义"
fi

# ========== 6. 完成提示 ==========
echo -e "\n✅ 已完成配置，请执行 \033[1msource ~/.bashrc\033[0m 或重启终端使配置生效。"
