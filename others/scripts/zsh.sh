#!/usr/bin/env bash
set -e

# ======================
# Configurable variables
# ======================
DOTFILES_DIR="${HOME}/dotfiles"
ZSH_DOTFILES_DIR="${DOTFILES_DIR}/zsh"
ZSHRC_DOTFILE="${ZSH_DOTFILES_DIR}/.zshrc"

# ======================
# Helper functions
# ======================

log() { printf "\033[1;32m[INFO]\033[0m %s\n" "$*"; }
warn() { printf "\033[1;33m[WARN]\033[0m %s\n" "$*"; }
err() { printf "\033[1;31m[ERR]\033[0m %s\n" "$*" >&2; }

have() { command -v "$1" >/dev/null 2>&1; }

# ======================
# 1. Install Oh My Zsh
# ======================

if [ ! -d "${HOME}/.oh-my-zsh" ]; then
  log "Installing Oh My Zsh (non-interactive)..."
  RUNZSH=no CHSH=no KEEP_ZSHRC=yes \
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
else
  log "Oh My Zsh already installed, skipping."
fi

# ======================
# 2. Install plugins (autosuggestions + syntax highlighting)
# ======================

ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

# zsh-autosuggestions
if [ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]; then
  log "Installing zsh-autosuggestions..."
  git clone https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
else
  log "zsh-autosuggestions already present, pulling latest..."
  git -C "$ZSH_CUSTOM/plugins/zsh-autosuggestions" pull || true
fi

# zsh-syntax-highlighting
if [ ! -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ]; then
  log "Installing zsh-syntax-highlighting..."
  git clone https://github.com/zsh-users/zsh-syntax-highlighting "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
else
  log "zsh-syntax-highlighting already present, pulling latest..."
  git -C "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" pull || true
fi

# ======================
# 3. Change default shell to zsh
# ======================

CURRENT_SHELL="${SHELL:-}"
ZSH_PATH="$(command -v zsh || true)"

if [ -n "$ZSH_PATH" ] && [ "$CURRENT_SHELL" != "$ZSH_PATH" ]; then
  log "Setting default shell to: $ZSH_PATH"
  if chsh -s "$ZSH_PATH"; then
    log "Default shell changed. You may need to log out and log back in."
  else
    warn "Could not change default shell automatically. Try: chsh -s \"$ZSH_PATH\""
  fi
else
  log "Default shell already zsh or zsh not found in PATH."
fi

log "Done! Start a new terminal or run: exec zsh"
