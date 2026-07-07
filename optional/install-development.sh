#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

source "$SCRIPT_DIR/../scripts/lib.sh"
source "$SCRIPT_DIR/../scripts/packages.sh"

header "Installing Development Packages"

PACKAGES=(
    docker
    docker-compose
    github-cli
    lazygit
)

install_pacman "${PACKAGES[@]}"

success "Development packages installed."
