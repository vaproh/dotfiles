#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

source "$SCRIPT_DIR/scripts/lib.sh"

header "Optional Components"

OPTIONAL_SCRIPTS=(
    "Development|optional/install-development.sh"
    "Docker|optional/install-docker.sh"
    "Gaming|optional/install-gaming.sh"
    "Laptop|optional/install-laptop.sh"
    "Neovim Config|optional/install-neovim.sh"
)

for item in "${OPTIONAL_SCRIPTS[@]}"; do

    IFS='|' read -r name script <<< "$item"

    if confirm "Install $name?"; then

        section "$name"

        bash "$SCRIPT_DIR/$script"

    else

        skip "$name skipped."

    fi

done

success "Optional installation complete."
