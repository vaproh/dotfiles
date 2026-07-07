#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

source "$SCRIPT_DIR/../.chezmoi_lib/lib.sh"
source "$SCRIPT_DIR/../.chezmoi_lib/packages.sh"

header "Installing Development Packages"

PACKAGES=(
    docker
    docker-compose
    github-cli
    lazygit
    nodejs
    npm
    just
)

install_pacman "${PACKAGES[@]}"

success "Development packages installed."
