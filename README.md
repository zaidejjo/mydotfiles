# zaid/dotfiles

Arch Linux dotfiles with interactive TUI installer. Manages packages (pacman + AUR) and deploys configs with timestamped backups.

## Quick Start

```bash
git clone https://github.com/zaid/mydotfiles.git ~/dotfiles
cd ~/dotfiles
./install.sh
```

## Menu Options

| Option | Action | Description |
|--------|--------|-------------|
| 1 | Full Install | Pacman + AUR + Dotfiles (recommended) |
| 2 | Pacman Packages | Install packages from `pkglist.txt` only |
| 3 | AUR Packages | Install packages from `aurlist.txt` only |
| 4 | Deploy Dotfiles | Backup + rsync configs to `~/.config/` and `~/` |
| 5 | Exit | |

## Manual Deploy

Skip the script and symlink/copy manually:

```bash
# Stow individual configs (if using GNU stow)
cd ~/dotfiles
stow -t ~ nvim
stow -t ~ tmux
stow -t ~ zsh

# Or rsync a specific config
rsync -avh nvim/ ~/.config/nvim/
```

Backup existing configs first:

```bash
mv ~/.config/nvim ~/.config/nvim.bak.$(date +%s)
```

## Directory Structure

```
mydotfiles/
├── install.sh              # TUI installer (menu-driven)
├── pkglist.txt             # Native pacman packages (308 entries)
├── aurlist.txt             # AUR packages (22 entries)
├── Backgrounds/            # Wallpapers → ~/Pictures/Backgrounds/
├── btop/                   # System monitor config
├── fastfetch/              # System info fetch config
├── ghostty/                # Ghostty terminal emulator config
├── icons/                  # Icon theme (dots → ~/.config/.icons)
├── nvim/                   # Neovim config
├── opencode/               # OpenCode editor config
├── plank/                  # Plank dock config
├── rofi/                   # Application launcher config
├── starship/               # Starship prompt config
├── themes/                 # GTK theme (dots → ~/.config/.themes)
├── tmux/                   # tmux config → ~/.tmux.conf
├── wezterm/                # WezTerm config → ~/.wezterm.lua
├── xfce/                   # XFCE desktop config
└── zsh/                    # Zsh config → ~/.zshrc
```

Config directories under version control mirror `~/.config/<name>/`. Home files (tmux, wezterm, zsh) deploy to `~/`.

## Requirements

- **Arch Linux** (requires `pacman`)
- **Nerd Font** installed (for menu icons). Otherwise menu text may render as boxes.
- **sudo** access (cached with keepalive during install)

### Optional

- `rsync` — dotfiles deploy uses it by default; falls back to `cp` if missing
- `yay` — auto-installed from AUR (`yay-bin`) when AUR install is selected

## Features

- Per-package error handling (no `set -e` — one failure won't kill the script)
- Timestamped `.bak` backups before overwriting existing configs
- Auto-installs `yay-bin` if missing when AUR install is selected
- Sudo credential caching with background keepalive
- ANSI colors + Nerd Font icons in TUI
