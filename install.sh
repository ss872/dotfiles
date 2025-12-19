#!/usr/bin/env sh
set -eu

# Top-level installer.
# - Runs package installation first
# - Then interactively asks before running other scripts

REPO_ROOT="$(cd "$(dirname "$0")" && pwd)"
SCRIPTS_DIR="$REPO_ROOT/others/scripts"

PACKAGES_FILE="$REPO_ROOT/others/packages.txt"
PACKAGES_SCRIPT="$SCRIPTS_DIR/install-packages.sh"

if [ ! -x "$PACKAGES_SCRIPT" ]; then
  printf 'ERROR: %s not found or not executable\n' "$PACKAGES_SCRIPT" >&2
  exit 1
fi

if [ -f "$PACKAGES_FILE" ]; then
  printf 'Run package installation from %s? [y/N] ' "$PACKAGES_FILE"
  read ans
  case "$ans" in
    y|Y)
      "$PACKAGES_SCRIPT" -f "$PACKAGES_FILE"
      ;;
    *)
      printf 'Skipping package installation\n'
      ;;
  esac
else
  printf 'No packages.txt found, skipping package installation\n'
fi

printf '\n'

for script in "$SCRIPTS_DIR"/*.sh; do
  [ "$script" = "$PACKAGES_SCRIPT" ] && continue
  [ -x "$script" ] || continue

  name="$(basename "$script")"

  printf 'Run %s? [y/N] ' "$name"
  read ans
  case "$ans" in
    y|Y)
      "$script"
      ;;
    *)
      printf 'Skipping %s\n' "$name"
      ;;
  esac
done
