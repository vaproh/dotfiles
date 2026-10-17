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
    rust-analyzer
    rust-src
    opencode

    # C / C++ toolchain (LLVM; clang also provides clangd)
    clang
    lld
    lldb
    llvm
    compiler-rt
    cmake
    ninja
    ccache
    gdb
)

AUR_PACKAGES=(
    rtk-bin
)

install_pacman "${PACMAN_PACKAGES[@]}"

# Latest stable Rust toolchain via rustup (installs if missing, updates if present)
if command_exists rustup; then
    info "Installing latest stable Rust toolchain via rustup"
    rustup default stable
    rustup update stable
fi

if [[ ${#AUR_PACKAGES[@]} -gt 0 ]]; then
    if gum confirmation --default=false "Install AUR packages?"; then
        install_aur "${AUR_PACKAGES[@]}"
    fi
fi

success "Development packages installed."
