#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

source "$SCRIPT_DIR/scripts/lib.sh"

header "Installing Yazi Plugins"

if ! command_exists ya; then
    die "Yazi package manager (ya) not found."
fi

section "Installing Plugins"

ya pkg install

success "Yazi plugins installed."

divider

success "Yazi setup complete."
