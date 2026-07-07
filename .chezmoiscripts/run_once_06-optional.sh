#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

source "$SCRIPT_DIR/../.chezmoi_lib/lib.sh"

header "Optional Components"

OPTIONAL_SCRIPTS=(
    "Development|../.chezmoi_optional/install-development.sh"
    "Docker|../.chezmoi_optional/install-docker.sh"
    "Gaming|../.chezmoi_optional/install-gaming.sh"
    "Laptop|../.chezmoi_optional/install-laptop.sh"
    "Neovim Config|../.chezmoi_optional/install-nvim.sh"
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
