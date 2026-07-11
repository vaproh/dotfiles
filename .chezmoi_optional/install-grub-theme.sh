#!/usr/bin/env bash

set -euo pipefail

SOURCE_DIR="${CHEZMOI_SOURCE_DIR:-$(chezmoi source-path)}"

source "$SOURCE_DIR/.chezmoi_lib/lib.sh"
source "$SOURCE_DIR/.chezmoi_lib/packages.sh"

header "GRUB Vimix Theme"

info "Installing grub-theme-vimix..."
install_pacman grub-theme-vimix

GRUB_CONFIG="/etc/default/grub"
BACKUP_CONFIG="${GRUB_CONFIG}.bak"

info "Backing up GRUB config..."
sudo cp "$GRUB_CONFIG" "$BACKUP_CONFIG"
success "Backup saved to $BACKUP_CONFIG"

info "Configuring GRUB theme..."
THEME_PATH="/usr/share/grub/themes/Vimix/theme.txt"

if grep -q "^#\?GRUB_THEME=" "$GRUB_CONFIG"; then
    sudo sed -i "s|^#\?GRUB_THEME=.*|GRUB_THEME=\"$THEME_PATH\"|" "$GRUB_CONFIG"
else
    echo "GRUB_THEME=\"$THEME_PATH\"" | sudo tee -a "$GRUB_CONFIG" >/dev/null
fi

success "GRUB_THEME set to $THEME_PATH"

info "Detecting boot mode..."
if [[ -d /sys/firmware/efi ]]; then
    BOOT_MODE="UEFI"
    GRUB_CFG="/boot/efi/EFI/arch/grub.cfg"
    [[ -f /boot/grub/grub.cfg ]] && GRUB_CFG="/boot/grub/grub.cfg"
else
    BOOT_MODE="BIOS"
    GRUB_CFG="/boot/grub/grub.cfg"
fi

info "Boot mode: $BOOT_MODE"
info "Generating GRUB config at $GRUB_CFG..."

sudo grub-mkconfig -o "$GRUB_CFG"

success "GRUB theme installed and config generated!"
info "Theme will be active on next boot."