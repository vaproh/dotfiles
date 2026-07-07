#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

source "$SCRIPT_DIR/scripts/lib.sh"
source "$SCRIPT_DIR/scripts/packages.sh"

header "Installing Fonts"

FONTS=(
    inter-font
    noto-fonts
    noto-fonts-cjk
    noto-fonts-emoji

    ttf-libertinus
    ttf-iodidone

    ttf-ioskeley-mono-nerd
    ttf-iosevka-nerd
    ttf-firacode-nerd
    ttf-jetbrains-mono-nerd
    maplemono-ttf

    ttf-twemoji
    ttf-joypixels

    ttf-nerd-fonts-symbols
    ttf-nerd-fonts-symbols-mono

    woff2-font-awesome

    otf-latin-modern
    otf-latinmodern-math
    otf-stix
    tex-gyre-math-fonts
)

section "Installing font packages"

install_aur "${FONTS[@]}"

section "Refreshing font cache"

refresh_fonts

section "Verifying fonts"

for font in \
    "Inter" \
    "Iosevka" \
    "Maple Mono" \
    "JetBrains Mono" \
    "Libertinus Serif"
do
    if fc-match "$font" >/dev/null 2>&1; then
        success "$font"
    else
        warn "$font not found"
    fi
done

success "Font installation complete."
