#!/usr/bin/env bash

set -euo pipefail

SOURCE_DIR="${CHEZMOI_SOURCE_DIR:-$(chezmoi source-path)}"

source "$SOURCE_DIR/.chezmoi_lib/lib.sh"
source "$SOURCE_DIR/.chezmoi_lib/packages.sh"

header "Installing Packages"

PACMAN_PACKAGES=(

    # --------------------------------------------------
    # Wayland
    # --------------------------------------------------

    hyprland
    hyprlock
    hypridle
    hyprshot
    hyprpicker
    hyprpaper

    # Niri (primary scrollable-tiling compositor) + Noctalia shell
    niri
    noctalia
    xwayland-satellite

    xdg-desktop-portal
    xdg-desktop-portal-hyprland
    xdg-desktop-portal-gtk
    xdg-desktop-portal-gnome
    xdg-utils

    brightnessctl
    udiskie
    wlsunset
    wtype
    wev

    # --------------------------------------------------
    # Bar / Launcher / Notifications
    # --------------------------------------------------

    waybar

    wofi

    swaync
    libnotify

    # --------------------------------------------------
    # Terminal
    # --------------------------------------------------

    kitty
    starship
    zsh
    tmux

    # --------------------------------------------------
    # Editor
    # --------------------------------------------------

    neovim

    # --------------------------------------------------
    # File Managers
    # --------------------------------------------------

    dolphin
    yazi

    gvfs
    gvfs-mtp
    udisks2-qt6

    # --------------------------------------------------
    # Clipboard
    # --------------------------------------------------

    copyq
    wl-clipboard
    wl-clip-persist
    cliphist

    # --------------------------------------------------
    # Audio
    # --------------------------------------------------

    pipewire
    pipewire-alsa
    pipewire-jack
    pipewire-pulse

    wireplumber

    gst-plugin-pipewire
    gst-plugins-base
    gst-plugins-good
    gst-plugins-bad
    gst-plugins-ugly

    pavucontrol-qt
    playerctl
    cava
    pamixer

    # --------------------------------------------------
    # Video
    # --------------------------------------------------

    mpv
    obs-studio

    satty
    grim
    slurp

    imv
    feh

    # --------------------------------------------------
    # Archives
    # --------------------------------------------------

    file-roller
    xarchiver

    7zip
    zip
    unzip
    unrar

    # --------------------------------------------------
    # Bluetooth
    # --------------------------------------------------

    bluez
    bluez-utils

    # --------------------------------------------------
    # System
    # --------------------------------------------------

    networkmanager
    wpa_supplicant

    hyprpolkitagent

    scrcpy
    android-tools

    flatpak

    # --------------------------------------------------
    # Appearance
    # --------------------------------------------------

    papirus-icon-theme
    gnome-themes-extra
    qt5ct
    qt6ct
    qt5-wayland
    qt6-wayland
    kvantum
    nwg-look

    # --------------------------------------------------
    # Applications
    # --------------------------------------------------

    discord
    telegram-desktop

    qbittorrent

    zathura
    zathura-pdf-poppler

    libreoffice-still

    qalculate-gtk

    gnome-software

    # --------------------------------------------------
    # System Info
    # --------------------------------------------------

    fastfetch
    btop
    mission-center

    # --------------------------------------------------
    # CLI
    # --------------------------------------------------

    jq
    fzf
    zoxide
    bat
    eza
    fd
    ripgrep
    tree
    ncdu

    curl
    wget
    rsync

    git
    npm
    just

    pacman-contrib

    chezmoi

    yt-dlp
    reflector

    # --------------------------------------------------
    # Python
    # --------------------------------------------------

    python
    python-pip
    python-pipx
    python-uv
    python-virtualenv
    python-pynvim

    # --------------------------------------------------
    # Development
    # --------------------------------------------------

    base-devel
    code
    devtools
)

AUR_PACKAGES=(

    # --------------------------------------------------
    # Wayland
    # --------------------------------------------------

    xwaylandvideobridge

    # --------------------------------------------------
    # Bar / Launcher
    # --------------------------------------------------

    wttrbar-bin
    wlogout
    wofi-calc

    # --------------------------------------------------
    # Utilities
    # --------------------------------------------------

    bemoji

    wayscriber-bin
    wayscriber-configurator

    # --------------------------------------------------
    # Appearance
    # --------------------------------------------------

    whitesur-icon-theme
    materia-gtk-theme
    qgnomeplatform-qt6

    python-pywal16

    # --------------------------------------------------
    # Applications
    # --------------------------------------------------

    brave-origin-bin
    zen-browser-bin
    spotify

    # --------------------------------------------------
    # Video
    # --------------------------------------------------

    awww
    waypaper
)

section "Installing Official Packages"

install_pacman "${PACMAN_PACKAGES[@]}"

if gum confirm --default=true "Install AUR packages?"; then
    section "Selecting AUR Packages"

    if command -v gum &>/dev/null; then
        SELECTED_AUR=$(gum choose --no-limit --header "Select AUR packages to install:" "${AUR_PACKAGES[@]}")
    else
        echo "Available AUR packages:"
        for i in "${!AUR_PACKAGES[@]}"; do
            echo "  $((i+1)). ${AUR_PACKAGES[i]}"
        done
        echo -n "Enter numbers (space-separated, or 'all'): "
        read -r selections
        if [[ "$selections" == "all" ]]; then
            SELECTED_AUR="${AUR_PACKAGES[*]}"
        else
            SELECTED_AUR=""
            for num in $selections; do
                idx=$((num - 1))
                if [[ $idx -ge 0 && $idx -lt ${#AUR_PACKAGES[@]} ]]; then
                    SELECTED_AUR="$SELECTED_AUR ${AUR_PACKAGES[idx]}"
                fi
            done
        fi
    fi

    if [[ -n "${SELECTED_AUR:-}" ]]; then
        install_aur $SELECTED_AUR
    else
        info "No AUR packages selected."
    fi
fi

success "Package installation complete."
