#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

source "$SCRIPT_DIR/../.chezmoi_lib/lib.sh"
source "$SCRIPT_DIR/../.chezmoi_lib/git.sh"

PLUGINS=(
    "zsh-users/zsh-autosuggestions"
    "zsh-users/zsh-syntax-highlighting"
    "unixorn/fzf-zsh-plugin"
    "MichaelAquilina/zsh-you-should-use"
    "Aloxaf/fzf-tab"
    "zsh-users/zsh-completions"
)

header "Installing Oh My Zsh"

if ! has_internet; then
    die "No internet connection."
fi

if ! command_exists curl; then
    die "curl is required."
fi

CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

# --------------------------------------------------
# Install Oh My Zsh
# --------------------------------------------------

if [[ ! -d "$HOME/.oh-my-zsh" ]]; then

    section "Installing Oh My Zsh"

    export RUNZSH=no
    export CHSH=no
    export KEEP_ZSHRC=yes

    sh -c "$(
        curl -fsSL \
        https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh
    )"

    success "Oh My Zsh installed."

else

    skip "Oh My Zsh already installed."

fi

# --------------------------------------------------
# Install Plugins
# --------------------------------------------------

section "Installing Plugins"

for plugin in "${PLUGINS[@]}"; do

    clone_repo \
        "https://github.com/${plugin}.git" \
        "$CUSTOM/plugins/${plugin##*/}"

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

for plugin in "${PLUGINS[@]}"; do
    success "${plugin##*/}"
done

divider

success "Oh My Zsh setup complete."
