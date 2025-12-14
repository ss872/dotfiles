#!/usr/bin/env sh
set -eu

LIST_FILE=""
DRY_RUN=0
MANAGER="" # optional override

usage() {
  cat <<'EOF'
Usage: scripts/install-packages.sh -f <packages.txt> [--dry-run] [--manager <mgr>]

Options:
  -f <file>          Package list file
  --dry-run          Print commands without executing
  --manager <mgr>    Override auto-detect: apt | dnf | pacman

Auto-detect order:
  apt -> dnf -> pacman
EOF
}

have() { command -v "$1" >/dev/null 2>&1; }

detect_manager() {
  if have apt-get; then echo apt; return; fi
  if have dnf; then echo dnf; return; fi
  if have pacman; then echo pacman; return; fi
  echo ""
}

run() {
  if [ "$DRY_RUN" -eq 1 ]; then
    printf '[dry-run] %s\n' "$*"
  else
    sh -c "$*"
  fi
}

while [ $# -gt 0 ]; do
  case "$1" in
    -f) LIST_FILE="$2"; shift 2 ;;
    --dry-run) DRY_RUN=1; shift ;;
    --manager) MANAGER="$2"; shift 2 ;;
    -h|--help) usage; exit 0 ;;
    *) printf 'ERROR: unknown arg: %s\n' "$1" >&2; exit 1 ;;
  esac
done

[ -n "$LIST_FILE" ] || { printf 'ERROR: package list required (-f)\n' >&2; exit 1; }
[ -f "$LIST_FILE" ] || { printf 'ERROR: list not found: %s\n' "$LIST_FILE" >&2; exit 1; }

packages="$(grep -v '^\s*#' "$LIST_FILE" | grep -v '^\s*$' || true)"
[ -n "${packages:-}" ] || exit 0

if [ -z "$MANAGER" ]; then
  MANAGER="$(detect_manager)"
fi

[ -n "$MANAGER" ] || {
  printf 'ERROR: could not detect a supported package manager (apt/dnf/pacman)\n' >&2
  exit 1
}

printf 'Using package manager: %s\n' "$MANAGER"

case "$MANAGER" in
  apt)
    run "sudo apt-get update"
    for p in $packages; do
      run "dpkg -s $p >/dev/null 2>&1 || sudo apt-get install -y $p"
    done
    ;;
  dnf)
    for p in $packages; do
      run "rpm -q $p >/dev/null 2>&1 || sudo dnf install -y $p"
    done
    ;;
  pacman)
    for p in $packages; do
      run "pacman -Qi $p >/dev/null 2>&1 || sudo pacman -S --needed --noconfirm $p"
    done
    ;;
  *)
    printf 'ERROR: unsupported manager: %s\n' "$MANAGER" >&2
    exit 1
    ;;
esac
