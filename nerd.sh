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
