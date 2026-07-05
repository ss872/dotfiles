#!/usr/bin/env bash

set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET_DIR="${HOME}"
DRY_RUN=false
INTERACTIVE=true
ADOPT=true
INSTALL_SYSTEM=false
STOW_DOTFILES=true

usage() {
  cat <<EOF
Usage: ./install.sh [options]

Options:
  --all             Use all discovered dotfile packages without opening the picker
  --install-system  Install matching system packages before stowing
  --packages-only   Install matching system packages without stowing dotfiles
  --stow-only       Stow dotfiles without installing system packages (default)
  --dry-run         Show what would happen without changing files
  --adopt           Move conflicting target files into this repo before stowing (default)
  --no-adopt        Do not adopt conflicting target files
  -h, --help        Show this help

Interactive controls:
  gum picker: arrows/j/k to move, space to select, enter to confirm
EOF
}

die() {
  printf 'Error: %s\n' "$*" >&2
  exit 1
}

has() {
  command -v "$1" >/dev/null 2>&1
}

detect_package_manager() {
  if has dnf; then
    printf 'dnf\n'
  elif has pacman; then
    printf 'pacman\n'
  elif has apt-get; then
    printf 'apt\n'
  else
    return 1
  fi
}

install_command_for() {
  local manager="$1"
  shift

  case "${manager}" in
    dnf)
      printf 'sudo dnf install -y --skip-unavailable'
      ;;
    pacman)
      printf 'sudo pacman -S --needed'
      ;;
    apt)
      printf 'sudo apt-get install -y'
      ;;
  esac

  printf ' %q' "$@"
  printf '\n'
}

missing_gum_error() {
  local manager command

  manager="$(detect_package_manager 2>/dev/null || true)"
  case "${manager}" in
    dnf | pacman | apt)
      command="$(install_command_for "${manager}" gum)"
      ;;
    *)
      command='Install gum from https://github.com/charmbracelet/gum'
      ;;
  esac

  printf 'Error: gum is required for the interactive installer.\n' >&2
  printf 'Install it with:\n  %s\n' "${command}" >&2
  printf 'Then rerun ./install.sh, or use ./install.sh --all for non-interactive mode.\n' >&2
  exit 1
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --all)
      INTERACTIVE=false
      ;;
    --dry-run)
      DRY_RUN=true
      ;;
    --install-system)
      INSTALL_SYSTEM=true
      STOW_DOTFILES=true
      ;;
    --packages-only)
      INSTALL_SYSTEM=true
      STOW_DOTFILES=false
      ;;
    --stow-only)
      INSTALL_SYSTEM=false
      STOW_DOTFILES=true
      ;;
    --adopt)
      ADOPT=true
      ;;
    --no-adopt)
      ADOPT=false
      ;;
    -h | --help)
      usage
      exit 0
      ;;
    *)
      die "Unknown option: $1"
      ;;
  esac
  shift
done

declare -A FEDORA_PACKAGES=(
  [fish]="fish"
  [fuzzel]="fuzzel"
  [ghostty]="ghostty"
  [niri]="niri"
  [nvim]="neovim"
  [swayidle]="swayidle"
  [swaylock]="swaylock"
  [tmux]="tmux"
  [waybar]="waybar"
  [zellij]="zellij"
)

mapfile -t packages < <(
  find "${DOTFILES_DIR}" -mindepth 1 -maxdepth 1 -type d \
    ! -name ".git" \
    -exec test -d "{}/.config" \; -print \
    | xargs -r -n1 basename \
    | sort
)

[[ "${#packages[@]}" -gt 0 ]] || die "No stow packages found in ${DOTFILES_DIR}."

print_header() {
  gum style --bold --foreground '#facc15' 'Dotfiles installer'
  gum style --foreground '#8a8f98' "Repo:   ${DOTFILES_DIR}"
  gum style --foreground '#8a8f98' "Target: ${TARGET_DIR}"
  printf '\n'
}

select_with_gum() {
  local action install_action

  action="$(
    gum choose \
      --height 8 \
      --cursor.foreground '#facc15' \
      --selected.foreground '#facc15' \
      --header.foreground '#facc15' \
      --header 'Which dotfiles do you want to use?' \
      'All packages' \
      'Choose packages' \
      'Dry run all packages' \
      'Quit'
  )"

  case "${action}" in
    'All packages')
      selected_packages=("${packages[@]}")
      ;;
    'Choose packages')
      mapfile -t selected_packages < <(
        printf '%s\n' "${packages[@]}" | gum choose \
          --no-limit \
          --ordered \
          --height 14 \
          --cursor.foreground '#facc15' \
          --selected.foreground '#facc15' \
          --header.foreground '#facc15' \
          --selected-prefix '✓ ' \
          --unselected-prefix '  ' \
          --header 'Select packages with space, confirm with enter'
      )
      ;;
    'Dry run all packages')
      DRY_RUN=true
      selected_packages=("${packages[@]}")
      ;;
    *)
      exit 0
      ;;
  esac

  [[ "${#selected_packages[@]}" -gt 0 ]] || return

  install_action="$(
    gum choose \
      --height 8 \
      --cursor.foreground '#facc15' \
      --selected.foreground '#facc15' \
      --header.foreground '#facc15' \
      --header 'What should the installer do?' \
      'Install packages and stow dotfiles' \
      'Stow dotfiles only' \
      'Install packages only'
  )"

  case "${install_action}" in
    'Install packages and stow dotfiles')
      INSTALL_SYSTEM=true
      STOW_DOTFILES=true
      ;;
    'Install packages only')
      INSTALL_SYSTEM=true
      STOW_DOTFILES=false
      ;;
    *)
      INSTALL_SYSTEM=false
      STOW_DOTFILES=true
      ;;
  esac
}

confirm_with_user() {
  local prompt="$1"

  if has gum; then
    gum confirm --default --affirmative 'Yes' --negative 'No' "${prompt}"
    return
  fi

  local answer
  read -r -p "${prompt} [Y/n]: " answer
  [[ -z "${answer}" || "${answer}" =~ ^[Yy]$ ]]
}

system_packages_for_selection() {
  local manager="$1"
  local package dotfile
  system_packages=()
  unmapped_packages=()

  for dotfile in "${selected_packages[@]}"; do
    package=''
    case "${manager}" in
      dnf)
        package="${FEDORA_PACKAGES[$dotfile]:-}"
        ;;
      *)
        package="${dotfile}"
        [[ "${dotfile}" == "nvim" ]] && package="neovim"
        ;;
    esac

    if [[ -n "${package}" ]]; then
      system_packages+=("${package}")
    else
      unmapped_packages+=("${dotfile}")
    fi
  done

  if ! has stow; then
    system_packages+=("stow")
  fi
}

run_system_install() {
  local manager
  local -a install_cmd display_cmd

  manager="$(detect_package_manager)" || die "No supported package manager found. Supported: dnf, pacman, apt-get."
  system_packages_for_selection "${manager}"

  if [[ "${#system_packages[@]}" -eq 0 ]]; then
    printf 'No mapped system packages for selection: %s\n' "${selected_packages[*]}"
    return
  fi

  if [[ "${#unmapped_packages[@]}" -gt 0 ]]; then
    printf 'No package mapping for: %s\n' "${unmapped_packages[*]}"
  fi

  case "${manager}" in
    dnf)
      install_cmd=(dnf install -y --skip-unavailable "${system_packages[@]}")
      ;;
    pacman)
      install_cmd=(pacman -S --needed "${system_packages[@]}")
      ;;
    apt)
      install_cmd=(apt-get install -y "${system_packages[@]}")
      ;;
  esac

  if [[ "${EUID}" -ne 0 ]]; then
    install_cmd=(sudo "${install_cmd[@]}")
  fi

  display_cmd=("${install_cmd[@]}")
  printf 'System packages: %s\n' "${system_packages[*]}"
  printf 'Install command:'
  printf ' %q' "${display_cmd[@]}"
  printf '\n\n'

  if [[ "${DRY_RUN}" == true ]]; then
    return
  fi

  confirm_with_user 'Install system packages now?' || return
  "${install_cmd[@]}"
}

ensure_stow() {
  local manager
  local -a install_cmd

  has stow && return

  manager="$(detect_package_manager)" || die "GNU stow is missing and no supported package manager was found. Install stow manually."

  printf 'GNU stow is not installed.\n'
  printf 'Install command: %s\n\n' "$(install_command_for "${manager}" stow)"

  if [[ "${DRY_RUN}" == true ]]; then
    return 1
  fi

  confirm_with_user 'Install GNU stow now?' || die "GNU stow is required to stow dotfiles."

  case "${manager}" in
    dnf)
      install_cmd=(dnf install -y --skip-unavailable stow)
      ;;
    pacman)
      install_cmd=(pacman -S --needed stow)
      ;;
    apt)
      install_cmd=(apt-get install -y stow)
      ;;
  esac

  if [[ "${EUID}" -ne 0 ]]; then
    install_cmd=(sudo "${install_cmd[@]}")
  fi

  "${install_cmd[@]}"
  has stow || die "GNU stow still is not available after install."
}

run_stow() {
  local -a stow_args=(-Rv)

  if ! ensure_stow; then
    printf 'Skipping stow dry run because GNU stow is not installed.\n'
    return
  fi

  "${DRY_RUN}" && stow_args+=(-n)
  "${ADOPT}" && stow_args+=(--adopt)

  printf 'Selected packages: %s\n' "${selected_packages[*]}"
  printf 'Mode: %s\n' "$([[ "${DRY_RUN}" == true ]] && printf 'dry run' || printf 'apply')"
  printf 'Install system packages: %s\n' "${INSTALL_SYSTEM}"
  printf 'Stow dotfiles: %s\n' "${STOW_DOTFILES}"
  printf 'Adopt conflicts: %s\n\n' "${ADOPT}"

  if [[ "${DRY_RUN}" == false ]]; then
    confirm_with_user 'Run stow now?' || exit 0
  fi

  stow "${stow_args[@]}" -d "${DOTFILES_DIR}" -t "${TARGET_DIR}" "${selected_packages[@]}"
}

selected_packages=()

if [[ "${INTERACTIVE}" == true ]] && ! has gum; then
  missing_gum_error
fi

if has gum; then
  print_header
else
  printf 'Dotfiles installer\n'
  printf 'Repo:   %s\n' "${DOTFILES_DIR}"
  printf 'Target: %s\n\n' "${TARGET_DIR}"
fi

if [[ "${INTERACTIVE}" == false ]]; then
  selected_packages=("${packages[@]}")
else
  select_with_gum
fi

if [[ "${#selected_packages[@]}" -eq 0 ]]; then
  printf 'No packages selected. Nothing to do.\n'
  exit 0
fi

if [[ "${INSTALL_SYSTEM}" == true ]]; then
  run_system_install
fi

if [[ "${STOW_DOTFILES}" == true ]]; then
  run_stow
fi

printf '\nDone.\n'
