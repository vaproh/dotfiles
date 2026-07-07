# Dotfiles

Arch Linux + Hyprland (Wayland) configuration managed with [chezmoi](https://www.chezmoi.io/).

## What's Included

- **Window Manager**: Hyprland + Waybar + Wofi + SwayNC
- **Terminal**: Kitty + Zsh + Oh My Zsh + Starship
- **Editor**: Neovim (AstroNvim)
- **File Manager**: Dolphin + Yazi
- **Shell Tools**: fzf, zoxide, bat, eza, fd, ripgrep, jq
- **Fonts**: Inter, Iosevka, JetBrains Mono, Maple Mono, Nerd Fonts, Emoji
- **Appearance**: Papirus icons, Materia theme, Kvantum, Pywal

## Prerequisites

- Fresh Arch Linux installation
- Internet connection
- Git (will be installed by the bootstrap script if missing)

## Fresh Install

```bash
# Install chezmoi and initialize dotfiles
curl -fsLS https://get.chezmoi.io | sh
chezmoi init --apply vaproh
```

This will execute the following scripts in order:

| Script | Description |
|--------|-------------|
| `run_once_00-install-yay.sh` | Install yay (AUR helper) |
| `run_once_01-install-packages.sh` | Install all packages (~240 packages) |
| `run_once_02-install-fonts.sh` | Install fonts (~20 packages) |
| `run_once_03-install-ohmyzsh.sh` | Install Oh My Zsh + plugins |
| `run_once_04-enable-services.sh` | Enable services (NetworkManager, Pipewire, WirePlumber) |
| `run_once_05-install-yazi-plugins.sh` | Install Yazi plugins |
| `run_once_06-optional.sh` | Interactive menu for optional components |
| `run_once_07-install-tmux-plugins.sh` | Install TPM + Tmux plugins |
| `run_once_08-post-install.sh` | Post-install summary and instructions |

## Optional Components

During initial setup, `run_once_06-optional.sh` will prompt you to install optional components. You can also install them manually:

```bash
chezmoi cd
bash .chezmoi_optional/install-gaming.sh      # Steam, Proton, Wine, MangoHud
bash .chezmoi_optional/install-laptop.sh      # Power management, Bluetooth
bash .chezmoi_optional/install-development.sh # Docker, GitHub CLI, Lazygit
bash .chezmoi_optional/install-docker.sh      # Docker with service setup
bash .chezmoi_optional/install-nvim.sh        # Clone Neovim config
```

Or run the interactive menu again:

```bash
chezmoi cd
bash .chezmoiscripts/run_once_06-optional.sh
```

## Structure

```
.
├── .chezmoiscripts/           # Run-once scripts (executed, not copied to home)
│   ├── run_once_00-install-yay.sh
│   ├── run_once_01-install-packages.sh
│   ├── run_once_02-install-fonts.sh
│   ├── run_once_03-install-ohmyzsh.sh
│   ├── run_once_04-enable-services.sh
│   ├── run_once_05-install-yazi-plugins.sh
│   ├── run_once_06-optional.sh
│   ├── run_once_07-install-tmux-plugins.sh
│   └── run_once_08-post-install.sh
├── .chezmoi_lib/              # Helper libraries (sourced by scripts)
│   ├── lib.sh                 # Colors, logging, utilities
│   ├── git.sh                 # Git helpers
│   ├── packages.sh            # Package installation helpers
│   └── services.sh            # Service management helpers
├── .chezmoi_optional/         # Optional install scripts (run manually)
│   ├── install-development.sh
│   ├── install-docker.sh
│   ├── install-gaming.sh
│   ├── install-laptop.sh
│   └── install-nvim.sh
├── dot_config/              # ~/.config/*
│   ├── hypr/               # Hyprland config
│   ├── waybar/             # Waybar config
│   ├── kitty/              # Kitty terminal
│   ├── wofi/               # App launcher
│   ├── swaync/             # Notifications
│   ├── btop/               # System monitor
│   ├── fastfetch/          # System info
│   ├── yazi/               # File manager
│   ├── zathura/            # PDF viewer
│   ├── fontconfig/         # Font configuration
│   ├── qt5ct/              # Qt5 theming
│   ├── qt6ct/              # Qt6 theming
│   ├── Kvantum/            # Qt theme engine
│   ├── MangoHud/           # Gaming overlay
│   └── starship.toml       # Shell prompt
├── dot_local/
│   └── bin/                # Scripts (~/.local/bin/*)
│       └── executable_verify  # System verification
├── dot_zshrc               # Zsh configuration
├── dot_gitconfig           # Git configuration
├── dot_tmux.conf           # Tmux configuration
├── dot_fzf.zsh             # Fzf integration
└── README.md
```

## Updating

```bash
# Pull latest changes and apply
chezmoi update

# Or manually
chezmoi cd
git pull
chezmoi apply
```

## Verifying

After installation, verify your system:

```bash
verify
```

This will check:
- Core programs (yay, chezmoi, git, zsh, tmux, kitty, Hyprland, Waybar, Neovim, Yazi)
- Fonts (Inter, Maple Mono, Libertinus Serif, Noto Sans)
- Services (NetworkManager, Bluetooth, MPD)
- Oh My Zsh and plugins
- Configuration files
- Optional software
- GPU information
- Chezmoi status
- Failed services

## Scripts

Located in `~/.local/bin/`:

| Script | Description |
|--------|-------------|
| `verify` | System verification |
| `cpu-mode` | Toggle CPU performance modes |
| `hyprland-keybind-help` | Show Hyprland keybindings |
| `nuclear_portal_hyprland` | Fix portal issues |
| `songinfo` | Show current playing song |

## Keybindings

| Key | Action |
|-----|--------|
| `SUPER + Return` | Terminal (Kitty) |
| `SUPER + Space` | App Launcher (Wofi) |
| `SUPER + Q` | Close Window |
| `SUPER + V` | Clipboard (CopyQ) |
| `SUPER + F` | Fullscreen |
| `SUPER + P` | Power Menu |
| `SUPER + A` | Change Theme |
| `SUPER + INSERT` | Screenshot |
| `SUPER + SHIFT + P` | Color Picker |
| `SUPER + SHIFT + F1` | Help Menu |

## Hardware

- **GPU**: NVIDIA (proprietary drivers)
- **Audio**: PipeWire + WirePlumber
- **Network**: NetworkManager

## Troubleshooting

### Scripts not running

If scripts don't run during `chezmoi apply`, check:

```bash
# Check chezmoi status
chezmoi status

# Dry run to see what would happen
chezmoi apply --dry-run --verbose

# Run with verbose output
chezmoi apply --verbose
```

### Reset script state

To re-run `run_once_` scripts:

```bash
# Clear script state
chezmoi state delete-bucket --bucket=scriptState

# Then apply again
chezmoi apply
```

### Check for common issues

```bash
# Run chezmoi doctor
chezmoi doctor
```

### Manual script execution

If you need to run a specific script:

```bash
chezmoi cd
bash .chezmoiscripts/run_once_01-install-packages.sh
```

## Credits

- [Hyprland](https://hyprland.org/)
- [AstroNvim](https://astronvim.com/)
- [Catppuccin](https://catppuccin.com/)
- [Kanagawa](https://github.com/rebelot/kanagawa.nvim)
