#!/usr/bin/env bash

set -euo pipefail

SOURCE_DIR="${CHEZMOI_SOURCE_DIR:-$(chezmoi source-path)}"

source "$SOURCE_DIR/.chezmoi_lib/lib.sh"

header "Installing TPM & Tmux Plugins"

TPM_DIR="$HOME/.tmux/plugins/tpm"

if [[ -d "$TPM_DIR" ]]; then
    skip "TPM already installed."
else
    step "Cloning TPM"
    git clone https://github.com/tmux-plugins/tpm "$TPM_DIR"
    success "TPM installed."
fi

section "Installing Plugins"

"$TPM_DIR/bin/install_plugins"

success "Tmux plugins installed."
