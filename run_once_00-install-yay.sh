#!/usr/bin/env bash

set -euo pipefail

source "$(dirname "$0")/scripts/lib.sh"
source "$(dirname "$0")/scripts/packages.sh"

header "Installing yay"

if command_exists yay; then
    skip "yay is already installed."
    exit 0
fi

if ! has_internet; then
    die "No internet connection."
fi

step "Installing build dependencies"

install_pacman git base-devel

TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT

step "Cloning yay"

git clone https://aur.archlinux.org/yay.git "$TMP_DIR/yay"

step "Building yay"

cd "$TMP_DIR/yay"

makepkg -si --noconfirm

success "yay installed successfully."

divider

info "Version"

yay --version
