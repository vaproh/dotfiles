#!/bin/bash
# Gaming mode toggle: DND, caffeine, animations off
# Mod+Shift+G

FLAG="/tmp/.niri-gaming-mode"
APPEARANCE="$HOME/.config/niri/categories/appearance.kdl"

if [ -f "$FLAG" ]; then
    rm "$FLAG"
    noctalia msg notification-dnd-set off
    noctalia msg caffeine-set off
    sed -i '/^    off$/d' "$APPEARANCE"
    niri msg action load-config-file
    notify-send "Gaming Mode" "OFF"
else
    touch "$FLAG"
    noctalia msg notification-dnd-set on
    noctalia msg caffeine-set on
    sed -i '/^animations {/a\    off' "$APPEARANCE"
    niri msg action load-config-file
    notify-send "Gaming Mode" "ON"
fi
