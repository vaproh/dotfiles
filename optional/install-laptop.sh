#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

source "$SCRIPT_DIR/../scripts/lib.sh"
source "$SCRIPT_DIR/../scripts/packages.sh"

header "Installing Laptop Packages"

PACKAGES=(
    power-profiles-daemon
    tlp
    upower
    blueman
)

install_pacman "${PACKAGES[@]}"

success "Laptop packages installed."
