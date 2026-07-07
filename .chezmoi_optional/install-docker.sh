#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

source "$SCRIPT_DIR/../.chezmoi_lib/lib.sh"
source "$SCRIPT_DIR/../.chezmoi_lib/packages.sh"
source "$SCRIPT_DIR/../.chezmoi_lib/services.sh"

header "Installing Docker"

PACKAGES=(
    docker
    docker-buildx
    docker-compose
)

section "Installing Packages"

install_pacman "${PACKAGES[@]}"

section "Configuring Docker"

enable_system_service docker
start_system_service docker

section "Adding User to Docker Group"

if groups "$USER" | grep -qw docker; then
    skip "User '$USER' is already in the docker group."
else
    sudo usermod -aG docker "$USER"
    success "Added '$USER' to the docker group."
fi

divider

warn "You must log out and back in for docker group changes to take effect."

success "Docker installation complete."
