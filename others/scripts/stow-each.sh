#!/usr/bin/env bash
set -euo pipefail

# Interactive (or automatic) GNU Stow runner
# Location: others/scripts/stow-each.sh

# Resolve repo root:
# others/scripts/stow-each.sh -> repo root is two levels up
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd -- "$SCRIPT_DIR/../.." && pwd)"

TARGET="$HOME"
ACTION="stow"        # stow | restow | delete
ADOPT=0
VERBOSE=1
AUTO_YES=0           # non-interactive mode

usage() {
  cat <<'EOF'
Usage: stow-each.sh [options]

Options:
  -t, --target DIR     Stow target (default: $HOME)
  -r, --restow         stow --restow
  -D, --delete         stow --delete
  -a, --adopt          stow --adopt
  -y, --yes            Non-interactive (stow everything)
  -q, --quiet          Disable verbose output
  -h, --help           Show help
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    -t|--target) TARGET="$2"; shift 2 ;;
    -r|--restow) ACTION="restow"; shift ;;
    -D|--delete) ACTION="delete"; shift ;;
    -a|--adopt)  ADOPT=1; shift ;;
    -y|--yes)    AUTO_YES=1; shift ;;
    -q|--quiet)  VERBOSE=0; shift ;;
    -h|--help)   usage; exit 0 ;;
    *) echo "Unknown option: $1"; usage; exit 2 ;;
  esac
done

command -v stow >/dev/null 2>&1 || {
  echo "Error: GNU stow is not installed." >&2
  exit 1
}

SKIP_DIRS=(
  "others"
  ".git"
  ".github"
  ".idea"
  ".vscode"
)

should_skip() {
  local d="$1"
  for s in "${SKIP_DIRS[@]}"; do
    [[ "$d" == "$s" ]] && return 0
  done
  return 1
}

STOW_CMD=(stow -d "$ROOT_DIR" -t "$TARGET")
[[ $VERBOSE -eq 1 ]] && STOW_CMD+=(-v)
[[ $ADOPT -eq 1 ]] && STOW_CMD+=(--adopt)

case "$ACTION" in
  stow)   STOW_CMD+=(--stow) ;;
  restow) STOW_CMD+=(--restow) ;;
  delete) STOW_CMD+=(--delete) ;;
esac

mapfile -t PACKAGES < <(
  find "$ROOT_DIR" -mindepth 1 -maxdepth 1 -type d -printf '%f\n' | sort
)

for pkg in "${PACKAGES[@]}"; do
  should_skip "$pkg" && continue

  if [[ $AUTO_YES -eq 1 ]]; then
    echo "Stowing $pkg"
    "${STOW_CMD[@]}" "$pkg"
    continue
  fi

  while true; do
    read -r -p "Stow '$pkg'? [y/N] " ans
    ans="${ans:-N}"
    case "$ans" in
      y|Y)
        "${STOW_CMD[@]}" "$pkg"
        break
        ;;
      n|N)
        break
        ;;
      *)
        echo "Answer y or n."
        ;;
    esac
  done
done
