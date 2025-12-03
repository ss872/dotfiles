
# --------- Oh My Zsh core ---------
export ZSH="$HOME/.oh-my-zsh"

# Theme (change to whatever you like: agnoster, robbyrussell, afowler, etc.)
ZSH_THEME="amuse"

# Plugins (autocomplete, autosuggestions, highlighting)
plugins=(
  git
  zsh-autosuggestions
  zsh-syntax-highlighting
)

source $ZSH/oh-my-zsh.sh

# --------- History ---------
HISTSIZE=5000
SAVEHIST=5000
HISTFILE="$HOME/.zsh_history"
setopt share_history
setopt inc_append_history

# --------- Completion tweaks ---------
# Oh My Zsh already runs compinit, but we can tweak styles.
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}' 'r:|[._-]=* r:|=*'

# Optional: enable more completion features
setopt auto_menu
setopt complete_in_word

# --------- General shell options ---------
setopt correct                    # autocorrect commands
setopt noclobber                  # don't overwrite files with >
setopt prompt_subst               # allow $(...) in prompt

# --------- PATH tweaks ---------
export PATH="$HOME/.local/bin:$PATH"

# --------- Aliases ---------
alias ll="ls -lah"
alias gs="git status"
alias gc="git commit"
alias gp="git push"
alias vi="nvim"
alias vim="nvim"

# --------- Fix plugin load order (syntax highlighting last) ---------
# If something seems off with highlighting, ensure this stays at the end.
if [ -f "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" ]; then
  source "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
fi
