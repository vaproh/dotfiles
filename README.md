# Dotfiles

Arch Linux + Hyprland (Wayland) configuration managed with [chezmoi](https://www.chezmoi.io/).

## What's Included

- **Window Manager**: Hyprland + Waybar + Wofi + SwayNC + Hypridle
- **Terminal**: Kitty + Zsh + Oh My Zsh + Starship
- **Editor**: Neovim (AstroNvim) + Crush (AI coding agent)
- **File Manager**: Dolphin + Yazi
- **Shell Tools**: fzf, zoxide, bat, eza, fd, ripgrep, jq
- **AI Tools**: opencode, crush (with MCP servers: Context7, Exa, Fetch, OpenAPI)
- **Fonts**: Inter, Iosevka, JetBrains Mono, Maple Mono, Nerd Fonts, Emoji
- **Appearance**: Papirus icons, Materia theme, Kvantum, Pywal
- **Templates**: `dot_example_zshenv` - API key template for AI tools
- **Media**: ncmpcpp (MPD client)
- **Utilities**: btop, fastfetch, wlogout, rofi, zathura, sxhkd

## Prerequisites

- Fresh Arch Linux installation
- Internet connection
- `git` and `base-devel` (will be installed by the bootstrap script if missing)

## Fresh Install

### Option 1: One-liner (recommended)

```bash
curl -fsLS https://get.chezmoi.io | sh; chezmoi init --apply vaproh
```

### Option 2: Step by step

```bash
# 1. Install chezmoi
curl -fsLS https://get.chezmoi.io | sh

# 2. Initialize dotfiles from GitHub
chezmoi init --apply vaproh
```

### What happens during install

chezmoi will clone this repository and execute scripts in order:

| # | Script | Description |
|---|--------|-------------|
| 0 | `run_once_00-install-yay.sh` | Install yay (AUR helper) |
| 1 | `run_once_01-install-packages.sh` | Install all packages (~240 packages) |
| 2 | `run_once_02-install-fonts.sh` | Install fonts (~20 packages) |
| 3 | `run_once_03-install-ohmyzsh.sh` | Install Oh My Zsh + plugins |
| 4 | `run_once_04-enable-services.sh` | Enable services (NetworkManager, PipeWire, WirePlumber) |
| 5 | `run_once_05-install-yazi-plugins.sh` | Install Yazi plugins |
| 6 | `run_once_06-optional.sh` | Interactive menu for optional components |
| 7 | `run_once_07-install-tmux-plugins.sh` | Install TPM + Tmux plugins |
| 8 | `run_once_08-post-install.sh` | Post-install summary and reboot prompt |

> **Note:** Scripts with `run_once_` prefix only execute once per unique content version. To re-run them, see [Troubleshooting](#reset-script-state).

## Optional Components

During initial setup, `run_once_06-optional.sh` will prompt you to install optional components. You can also install them manually:

```bash
chezmoi cd
bash .chezmoi_optional/install-gaming.sh      # Steam, Proton, Wine, MangoHud
bash .chezmoi_optional/install-laptop.sh      # Power management, Bluetooth
bash .chezmoi_optional/install-development.sh # Docker, GitHub CLI, Lazygit
bash .chezmoi_optional/install-docker.sh      # Docker with service setup
bash .chezmoi_optional/install-nvim.sh        # Clone Neovim config
bash .chezmoi_optional/install-sddm-theme.sh  # SDDM astronaut theme (10 variants)
bash .chezmoi_optional/install-grub-theme.sh  # GRUB Vimix theme
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
│   ├── install-grub-theme.sh
│   ├── install-laptop.sh
│   ├── install-nvim.sh
│   └── install-sddm-theme.sh
├── dot_config/                # ~/.config/*
│   ├── hypr/                  # Hyprland config (hypridle, input, animations)
│   ├── waybar/                # Waybar config
│   ├── kitty/                 # Kitty terminal + themes
│   ├── wofi/                  # App launcher
│   ├── swaync/                # Notifications + themes
│   ├── btop/                  # System monitor
│   ├── fastfetch/             # System info
│   ├── yazi/                  # File manager
│   ├── zathura/               # PDF viewer
│   ├── ncmpcpp/               # MPD client
│   ├── fontconfig/            # Font configuration
│   ├── qt5ct/                 # Qt5 theming
│   ├── qt6ct/                 # Qt6 theming
│   ├── Kvantum/               # Qt theme engine
│   ├── MangoHud/              # Gaming overlay
│   ├── rofi/                  # App launcher config + themes
│   ├── swaync/                # Notification center themes
│   ├── sxhkd/                 # Hotkey daemon (bspwm/dwm configs)
│   ├── opencode/              # OpenCode AI agent config (MCP: Context7, Exa, OpenAPI, Fetch)
│   ├── crush/                 # Crush AI agent config (MCP: Context7, Exa, Fetch)
│   ├── gtk-4.0/               # GTK4 theming
│   ├── kdeglobals/            # KDE globals
│   ├── starship.toml          # Shell prompt
│   └── wlogout/               # Logout menu + themes
├── dot_local/
│   └── bin/                   # Scripts (~/.local/bin/*)
│       └── executable_verify  # System verification
├── dot_zshrc                  # Zsh configuration
├── dot_gitconfig              # Git configuration
├── dot_tmux.conf              # Tmux configuration
├── dot_fzf.zsh                # Fzf integration
├── dot_example_zshenv         # Example zshenv with API keys
└── README.md
```

## Updating

```bash
# Pull latest changes and apply (recommended)
chezmoi update

# Or manually
chezmoi cd
git pull
chezmoi apply
```

> **Note:** `run_once_` scripts will not re-execute unless their content changes. See [Troubleshooting](#reset-script-state) to force re-run.

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

## AI Tools

| Tool | Config | MCP Servers |
|------|--------|-------------|
| **opencode** | `~/.config/opencode/opencode.jsonc` | Context7, Exa, OpenAPI, Fetch |
| **crush** | `~/.config/crush/crush.json` | Context7, Exa, Fetch |

Both tools include MCP server configurations for enhanced capabilities (web search, API docs, code search, etc.).

Copy the example zshenv to configure API keys:

```bash
cp ~/.local/share/chezmoi/dot_example_zshenv ~/.zshenv
# Edit ~/.zshenv and add your API keys
```

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

To re-run `run_once_` scripts (e.g., after adding new packages):

```bash
# Clear all script state
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

### Fresh start

To completely reset and start over:

```bash
# Remove chezmoi state
chezmoi purge

# Re-run init
curl -fsLS https://get.chezmoi.io | sh; chezmoi init --apply vaproh
```

## Credits

- [Hyprland](https://hyprland.org/)
- [AstroNvim](https://astronvim.com/)
- [Catppuccin](https://catppuccin.com/)
- [Kanagawa](https://github.com/rebelot/kanagawa.nvim)
