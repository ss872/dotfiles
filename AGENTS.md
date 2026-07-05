# Codex Agent Instructions

## Project Context

This repository is a personal GNU Stow dotfiles repo rooted at `/home/sshyam/dotfiles`.
Each top-level directory that contains `.config` is treated as a stow package and is
linked into `$HOME` by `install.sh`.

Primary desktop context:

- Wayland compositor: `niri`
- Locker: `swaylock`
- Idle/sleep integration: `swayidle`
- Bar: `waybar`
- Launcher: `fuzzel`
- Terminal: `ghostty`

The installer supports interactive and non-interactive use, package installation
planning, and stowing selected dotfile packages.

## Rules

- Do not install system packages directly. If a package is missing, give the exact
  install command and wait for the user to install it.
- Check package and command availability before depending on a tool. Prefer
  `command -v <tool>` for commands and use the detected package manager when
  suggesting install commands.
- Always update `install.sh` when adding, renaming, or removing a top-level
  dotfile package, or when a config introduces a new system dependency.
- Keep package mappings in `install.sh` current, especially
  `FEDORA_PACKAGES`.
- Use GNU Stow conventions. Do not manually copy files into `$HOME`; update the
  repo package and stow it.
- Avoid custom background scripts for desktop behavior when a standard tool
  handles it cleanly. For niri sleep locking, prefer `swayidle -w before-sleep`
  with `swaylock`.
- Preserve user changes. The worktree may be dirty; do not revert unrelated
  changes.
- Use `rg` for searches when available.
- Keep edits narrowly scoped to the requested behavior.

## Useful Commands

Check available commands:

```bash
command -v stow gum dnf pacman apt-get niri swayidle swaylock waybar fuzzel ghostty
```

Preview stowing one package:

```bash
stow -Rvn -d /home/sshyam/dotfiles -t /home/sshyam <package>
```

Apply stowing one package:

```bash
stow -Rv -d /home/sshyam/dotfiles -t /home/sshyam <package>
```

Use the installer without installing packages:

```bash
./install.sh --stow-only
```

Show the package install command without running it:

```bash
./install.sh --packages-only --dry-run --all
```
