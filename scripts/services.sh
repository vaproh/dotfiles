#!/usr/bin/env bash

enable_system_service() {

    local service="$1"

    if systemctl is-enabled "$service" >/dev/null 2>&1; then
        skip "$service already enabled."
    else
        step "Enabling $service"
        sudo systemctl enable "$service"
        success "$service enabled."
    fi
}

start_system_service() {

    local service="$1"

    if systemctl is-active "$service" >/dev/null 2>&1; then
        skip "$service already running."
    else
        step "Starting $service"
        sudo systemctl start "$service"
        success "$service started."
    fi
}

enable_user_service() {

    local service="$1"

    if systemctl --user is-enabled "$service" >/dev/null 2>&1; then
        skip "$service already enabled."
    else
        step "Enabling $service"
        systemctl --user enable "$service"
        success "$service enabled."
    fi
}

start_user_service() {

    local service="$1"

    if systemctl --user is-active "$service" >/dev/null 2>&1; then
        skip "$service already running."
    else
        step "Starting $service"
        systemctl --user start "$service"
        success "$service started."
    fi
}
