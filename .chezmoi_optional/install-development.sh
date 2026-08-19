#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

source "$SCRIPT_DIR/../.chezmoi_lib/lib.sh"
source "$SCRIPT_DIR/../.chezmoi_lib/packages.sh"

header "Installing Development Packages"

PACMAN_PACKAGES=(
    github-cli
    lazygit
    nodejs
    npm
    just
    pnpm
    go
    rustup
    opencode
)

AUR_PACKAGES=(
    rtk-bin
)

install_pacman "${PACMAN_PACKAGES[@]}"

if [[ ${#AUR_PACKAGES[@]} -gt 0 ]]; then
    if gum confirmation --default=false "Install AUR packages?"; then
        install_aur "${AUR_PACKAGES[@]}"
    fi
fi

success "Development packages installed."
