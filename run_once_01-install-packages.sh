#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

source "$SCRIPT_DIR/scripts/lib.sh"
source "$SCRIPT_DIR/scripts/packages.sh"

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

    xdg-desktop-portal
    xdg-desktop-portal-hyprland
    xdg-utils
    xwaylandvideobridge

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
    wofi-calc

    swaync
    libnotify

    wlogout

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

    swww
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
    qgnomeplatform-qt6
    nwg-look

    # --------------------------------------------------
    # Applications
    # --------------------------------------------------

    discord
    telegram-desktop
    spotify

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
    # Bar
    # --------------------------------------------------

    wttrbar-bin

    # --------------------------------------------------
    # Utilities
    # --------------------------------------------------

    bemoji

    wayscriber-bin
    wayscriber-configurator

    # --------------------------------------------------
    # Appearance
    # --------------------------------------------------

    tela-circle-icon-theme
    whitesur-icon-theme
    candy-icons
    materia-gtk-theme

    python-pywal16

    # --------------------------------------------------
    # Applications
    # --------------------------------------------------

    brave-origin-bin

    # --------------------------------------------------
    # Video
    # --------------------------------------------------

    awww
    waypaper
)

section "Installing Official Packages"

install_pacman "${PACMAN_PACKAGES[@]}"

section "Installing AUR Packages"

install_aur "${AUR_PACKAGES[@]}"

success "Package installation complete."
