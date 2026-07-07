#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

source "$SCRIPT_DIR/../.chezmoi_lib/lib.sh"

header "Bootstrap Complete"

# --------------------------------------------------
# Installation Summary
# --------------------------------------------------

section "Installation Summary"

success "yay installed"
success "Packages installed"
success "Fonts installed"
success "Oh My Zsh installed"
success "Services configured"
success "Yazi plugins installed"
success "Tmux plugins installed"

divider

# --------------------------------------------------
# System Information
# --------------------------------------------------

section "System Information"

CPU="$(lscpu | awk -F: '/Model name/ {gsub(/^[ \t]+/, "", $2); print $2; exit}')"
GPU="$(lspci | grep -Ei 'VGA|3D|Display' | head -n1 | cut -d: -f3- | sed 's/^ //')"
KERNEL="$(uname -r)"
HOSTNAME="$(hostname)"

printf "%-10s %s\n" "Hostname:" "$HOSTNAME"
printf "%-10s %s\n" "Kernel:" "$KERNEL"
printf "%-10s %s\n" "CPU:" "$CPU"
printf "%-10s %s\n" "GPU:" "$GPU"

divider

# --------------------------------------------------
# Hardware Detection
# --------------------------------------------------

section "Hardware Detection"

if lspci | grep -qi nvidia; then

    info "Detected NVIDIA GPU"

    echo
    echo "Install the appropriate NVIDIA driver for your kernel."
    echo "https://wiki.archlinux.org/title/NVIDIA"

elif lspci | grep -Eqi 'amd|radeon'; then

    info "Detected AMD GPU"

    echo
    echo "Verify Mesa/Vulkan packages are installed."
    echo "https://wiki.archlinux.org/title/AMDGPU"

elif lspci | grep -qi intel; then

    info "Detected Intel GPU"

    echo
    echo "Verify Intel graphics packages are installed."
    echo "https://wiki.archlinux.org/title/Intel_graphics"

else

    warn "Unable to determine GPU."

fi

echo

info "Hardware Video Acceleration"

echo "https://wiki.archlinux.org/title/Hardware_video_acceleration"

divider

# --------------------------------------------------
# Optional Components
# --------------------------------------------------

section "Optional Components"

if [[ -d /sys/class/power_supply/BAT0 ]]; then
    info "Laptop detected."
    echo "Run optional/install-laptop.sh if you haven't already."
fi

if ! command -v docker >/dev/null 2>&1; then
    info "Docker not installed."
    echo "Run optional/install-docker.sh if needed."
fi

divider

# --------------------------------------------------
# Recommended Next Steps
# --------------------------------------------------

section "Recommended Next Steps"

echo "• Reboot your system."
echo "• Login to GitHub."
echo "• Login to Discord."
echo "• Login to Spotify."
echo "• Login to Telegram."
echo "• Restore SSH keys (if applicable)."
echo "• Restore GPG keys (if applicable)."

divider

# --------------------------------------------------
# Useful Commands
# --------------------------------------------------

section "Useful Commands"

cat <<EOF
chezmoi status
chezmoi update

fastfetch

systemctl --failed
systemctl --user --failed

fc-match monospace
fc-match sans-serif

git config --list

docker info

nvim
EOF

divider

# --------------------------------------------------
# Finish
# --------------------------------------------------

success "Bootstrap completed successfully."

echo
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Your system is ready. A reboot is strongly recommended."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
