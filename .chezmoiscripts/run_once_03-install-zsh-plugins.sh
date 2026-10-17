#!/usr/bin/env bash

set -euo pipefail

SOURCE_DIR="${CHEZMOI_SOURCE_DIR:-$(chezmoi source-path)}"

source "$SOURCE_DIR/.chezmoi_lib/lib.sh"
source "$SOURCE_DIR/.chezmoi_lib/git.sh"

# repo:destination-name pairs (dest names must match what dot_zshrc sources)
PLUGINS=(
    "zsh-users/zsh-autosuggestions:zsh-autosuggestions"
    "zsh-users/zsh-syntax-highlighting:zsh-syntax-highlighting"
    "Aloxaf/fzf-tab:fzf-tab"
    "MichaelAquilina/zsh-you-should-use:you-should-use"
)

PLUGIN_DIR="$HOME/.zsh/plugins"

header "Installing Zsh plugins"

if ! has_internet; then
    die "No internet connection."
fi

if ! command_exists git; then
    die "git is required."
fi

# --------------------------------------------------
# Install Plugins
# --------------------------------------------------

section "Installing plugins"

for entry in "${PLUGINS[@]}"; do
    repo="${entry%%:*}"
    name="${entry##*:}"
    clone_repo "https://github.com/${repo}.git" "$PLUGIN_DIR/$name"
done

success "Plugins installed."

# --------------------------------------------------
# Default Shell
# --------------------------------------------------

section "Changing Default Shell"

if [[ "$SHELL" != "$(command -v zsh)" ]]; then

    step "Setting default shell to zsh"

    chsh -s "$(command -v zsh)"

    success "Default shell changed."

else

    skip "zsh is already the default shell."

fi

# --------------------------------------------------
# Summary
# --------------------------------------------------

divider

info "Installed plugins"

for entry in "${PLUGINS[@]}"; do
    success "${entry##*:}"
done

divider

success "Zsh setup complete."
