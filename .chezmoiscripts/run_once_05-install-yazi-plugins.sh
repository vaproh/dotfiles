#!/usr/bin/env bash

set -euo pipefail

SOURCE_DIR="${CHEZMOI_SOURCE_DIR:-$(chezmoi source-path)}"

source "$SOURCE_DIR/.chezmoi_lib/lib.sh"

header "Installing Yazi Plugins"

if ! command_exists ya; then
    die "Yazi package manager (ya) not found."
fi

section "Installing Plugins"

ya pkg install

success "Yazi plugins installed."

divider

success "Yazi setup complete."
