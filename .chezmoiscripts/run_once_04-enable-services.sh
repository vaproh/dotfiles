#!/usr/bin/env bash

set -euo pipefail

SOURCE_DIR="${CHEZMOI_SOURCE_DIR:-$(chezmoi source-path)}"

source "$SOURCE_DIR/.chezmoi_lib/lib.sh"
source "$SOURCE_DIR/.chezmoi_lib/services.sh"

SYSTEM_SERVICES=(
    NetworkManager
    pipewire
    wireplumber
)

USER_SERVICES=(
)

header "Configuring Services"

section "System Services"

for service in "${SYSTEM_SERVICES[@]}"; do

    enable_system_service "$service"
    start_system_service "$service"

done

section "User Services"

for service in "${USER_SERVICES[@]}"; do

    enable_user_service "$service"
    start_user_service "$service"

done

divider

success "Services configured successfully."
