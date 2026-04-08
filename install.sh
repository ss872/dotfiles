#!/usr/bin/env bash

set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET_DIR="${HOME}"

if ! command -v stow >/dev/null 2>&1; then
  echo "Error: GNU stow is not installed."
  echo "Install it first, then rerun this script."
  exit 1
fi

mapfile -t packages < <(
  find "${DOTFILES_DIR}" -mindepth 1 -maxdepth 1 -type d \
    ! -name ".git" \
    -exec test -d "{}/.config" \; -print \
    | xargs -r -n1 basename \
    | sort
)

if [[ "${#packages[@]}" -eq 0 ]]; then
  echo "No stow packages found in ${DOTFILES_DIR}."
  exit 0
fi

print_packages() {
  local -n arr_ref=$1
  local i=1
  for pkg in "${arr_ref[@]}"; do
    echo "  ${i}. ${pkg}"
    ((i++))
  done
}

contains_pkg() {
  local needle="$1"
  shift
  local item
  for item in "$@"; do
    [[ "${item}" == "${needle}" ]] && return 0
  done
  return 1
}

echo "Dotfiles dir : ${DOTFILES_DIR}"
echo "Target dir   : ${TARGET_DIR}"
echo "Found packages:"
print_packages packages
echo

read -r -p "Symlink all packages? [Y/n]: " all_choice
all_choice="${all_choice:-y}"

selected_packages=("${packages[@]}")

if [[ "${all_choice}" =~ ^[Nn]$ ]]; then
  echo
  read -r -p "Enter package names to skip (comma or space separated): " skip_input

  if [[ -n "${skip_input// }" ]]; then
    normalized_skips="$(echo "${skip_input}" | tr ',' ' ')"
    read -r -a skip_packages <<< "${normalized_skips}"

    selected_packages=()
    for pkg in "${packages[@]}"; do
      if ! contains_pkg "${pkg}" "${skip_packages[@]}"; then
        selected_packages+=("${pkg}")
      fi
    done

    for skip_pkg in "${skip_packages[@]}"; do
      if ! contains_pkg "${skip_pkg}" "${packages[@]}"; then
        echo "Warning: package not found, skipping ignore entry: ${skip_pkg}"
      fi
    done
  fi
fi

if [[ "${#selected_packages[@]}" -eq 0 ]]; then
  echo "No packages selected. Nothing to do."
  exit 0
fi

echo
echo "Stowing packages: ${selected_packages[*]}"
stow -Rv --adopt -d "${DOTFILES_DIR}" -t "${TARGET_DIR}" "${selected_packages[@]}"

echo
echo "Symlinks set up successfully."
