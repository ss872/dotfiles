#!/usr/bin/env bash
set -e

# 1) Download JetBrains Mono Nerd Font
echo "Downloading JetBrains Mono Nerd Font..."
TMPDIR="$(mktemp -d)"
cd "$TMPDIR"

# Nerd Fonts latest JetBrainsMono zip
FONT_ZIP="JetBrainsMono.zip"
FONT_URL="https://github.com/ryanoasis/nerd-fonts/releases/latest/download/${FONT_ZIP}"

curl -fL "$FONT_URL" -o "$FONT_ZIP"

# 2) Install to user font directory
echo "Installing fonts to ~/.local/share/fonts ..."
mkdir -p "$HOME/.local/share/fonts"
unzip -q "$FONT_ZIP" -d "$HOME/.local/share/fonts"

# Rebuild font cache
echo "Updating font cache..."
fc-cache -fv > /dev/null 2>&1 || true

# 3) Configure Alacritty to use JetBrainsMono Nerd Font
ALACRITTY_DIR="$HOME/.config/alacritty"
ALACRITTY_CFG="$ALACRITTY_DIR/alacritty.yml"

mkdir -p "$ALACRITTY_DIR"

# If config doesn't exist, create a minimal one
if [ ! -f "$ALACRITTY_CFG" ]; then
  cat > "$ALACRITTY_CFG" << 'EOF'
# Alacritty configuration
font:
  normal:
    family: JetBrainsMono Nerd Font
    style: Regular

  bold:
    family: JetBrainsMono Nerd Font
    style: Bold

  italic:
    family: JetBrainsMono Nerd Font
    style: Italic

  bold_italic:
    family: JetBrainsMono Nerd Font
    style: Bold Italic

  size: 13.0
EOF
  echo "Created new $ALACRITTY_CFG with JetBrainsMono Nerd Font."
else
  # If config exists, append a font block with a comment so you can adjust/merge
  cat >> "$ALACRITTY_CFG" << 'EOF'

# --- Added by JetBrainsMono Nerd Font setup script ---
font:
  normal:
    family: JetBrainsMono Nerd Font
    style: Regular

  bold:
    family: JetBrainsMono Nerd Font
    style: Bold

  italic:
    family: JetBrainsMono Nerd Font
    style: Italic

  bold_italic:
    family: JetBrainsMono Nerd Font
    style: Bold Italic

  size: 13.0
# --- End of added block ---
EOF
  echo "Appended a JetBrainsMono Nerd Font block to $ALACRITTY_CFG."
  echo "If you already had a 'font:' section, you may want to remove or comment the old one."
fi

echo "Done! Restart Alacritty to see JetBrainsMono Nerd Font in action."
