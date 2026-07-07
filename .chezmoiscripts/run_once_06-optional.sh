#!/usr/bin/env bash

set -euo pipefail

SOURCE_DIR="${CHEZMOI_SOURCE_DIR:-$(chezmoi source-path)}"

source "$SOURCE_DIR/.chezmoi_lib/lib.sh"

header "Optional Components"

OPTIONAL_SCRIPTS=(
    "Development|install-development.sh"
    "Docker|install-docker.sh"
    "Gaming|install-gaming.sh"
    "Laptop|install-laptop.sh"
    "Neovim Config|install-nvim.sh"
)

for item in "${OPTIONAL_SCRIPTS[@]}"; do

    IFS='|' read -r name script <<< "$item"

    if confirm "Install $name?"; then

        section "$name"

        bash "$SOURCE_DIR/.chezmoi_optional/$(basename "$script")"

    else

        skip "$name skipped."

    fi

done

success "Optional installation complete."
