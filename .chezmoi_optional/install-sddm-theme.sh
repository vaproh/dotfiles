#!/usr/bin/env bash

set -euo pipefail

SOURCE_DIR="${CHEZMOI_SOURCE_DIR:-$(chezmoi source-path)}"

source "$SOURCE_DIR/.chezmoi_lib/lib.sh"
source "$SOURCE_DIR/.chezmoi_lib/packages.sh"

header "SDDM Astronaut Theme"

info "Installing dependencies..."
install_pacman sddm qt6-svg qt6-virtualkeyboard qt6-multimedia-ffmpeg

info "Cloning theme repository..."
THEME_DIR="/usr/share/sddm/themes/sddm-astronaut-theme"
if [[ -d "$THEME_DIR" ]]; then
    warn "Theme directory exists, backing up..."
    sudo mv "$THEME_DIR" "${THEME_DIR}_$(date +%s)"
fi

sudo git clone -b master --depth 1 https://github.com/Keyitdev/sddm-astronaut-theme.git "$THEME_DIR"

info "Installing fonts..."
if [[ -d "$THEME_DIR/Fonts" ]]; then
    sudo cp -r "$THEME_DIR/Fonts"/* /usr/share/fonts/
    fc-cache -fv >/dev/null 2>&1 || true
fi

info "Configuring SDDM..."
sudo mkdir -p /etc/sddm.conf.d

echo "[Theme]
Current=sddm-astronaut-theme" | sudo tee /etc/sddm.conf.d/theme.conf >/dev/null

echo "[General]
InputMethod=qtvirtualkeyboard" | sudo tee /etc/sddm.conf.d/virtualkbd.conf >/dev/null

THEMES=(
    "astronaut"
    "black_hole"
    "cyberpunk"
    "hyprland_kath"
    "jake_the_dog"
    "japanese_aesthetic"
    "pixel_sakura"
    "pixel_sakura_static"
    "post-apocalyptic_hacker"
    "purple_leaves"
)

SELECTED_THEME="astronaut"

if command -v gum &>/dev/null; then
    SELECTED_THEME=$(gum choose --cursor.foreground 12 --header "Select SDDM theme variant:" "${THEMES[@]}" || echo "astronaut")
else
    info "Available themes:"
    for i in "${!THEMES[@]}"; do
        echo "  $((i+1)). ${THEMES[i]}"
    done
    echo -n "Select theme [1-${#THEMES[@]}] (default 1): "
    read -r choice
    if [[ "$choice" =~ ^[0-9]+$ ]] && (( choice >= 1 && choice <= ${#THEMES[@]} )); then
        SELECTED_THEME="${THEMES[$((choice-1))]}"
    fi
fi

info "Setting theme variant: $SELECTED_THEME"
sudo sed -i "s|^ConfigFile=.*|ConfigFile=Themes/${SELECTED_THEME}.conf|" "$THEME_DIR/metadata.desktop"

success "SDDM theme configured with variant: $SELECTED_THEME"

if confirm "Enable SDDM service?"; then
    info "Enabling SDDM..."
    sudo systemctl disable display-manager.service 2>/dev/null || true
    sudo systemctl enable sddm.service
    success "SDDM service enabled. Reboot to apply."
else
    warn "SDDM service not enabled. Run 'sudo systemctl enable sddm.service' manually when ready."
fi