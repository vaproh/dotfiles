#!/usr/bin/env bash

install_pacman() {
    info "Installing: $*"
    sudo pacman -S --needed --noconfirm "$@"
}

install_aur() {
    info "Installing: $*"
    yay -S --needed "$@"
}

remove_pacman() {
    info "Removing: $*"
    sudo pacman -Rns "$@"
}

remove_aur() {
    info "Removing: $*"
    yay -Rns "$@"
}

update_system() {
    info "Updating: $*"
    yay -Syu
}
