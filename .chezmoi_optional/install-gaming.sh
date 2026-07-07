#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

source "$SCRIPT_DIR/../.chezmoi_lib/lib.sh"
source "$SCRIPT_DIR/../.chezmoi_lib/packages.sh"

header "Installing Gaming Packages"

PACMAN=(
    gamemode
    lib32-gamemode
    steam
    mangohud
    goverlay
    vkbasalt
    vkbasalt-cli
    gamescope
    vkd3d
    lib32-vkd3d
    wine
    wine-gecko
    wine-mono
    winetricks
    prismlauncher
    protontricks
)

AUR=(
    dxvk-bin
    protonup-qt-bin
    protontricks-bin
)

install_pacman "${PACMAN[@]}"
install_aur "${AUR[@]}"

success "Gaming packages installed."
