#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

source "$SCRIPT_DIR/../scripts/lib.sh"
source "$SCRIPT_DIR/../scripts/git.sh"

header "Installing Neovim Configuration"

DEST="$HOME/.config/nvim"

if [[ -d "$DEST/.git" ]]; then
    skip "Neovim configuration already installed."
    exit 0
fi

clone_repo \
    "https://github.com/vaproh/nvim.git" \
    "$DEST"

success "Neovim configuration installed."
