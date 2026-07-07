#!/usr/bin/env bash

clone_repo() {

    local url="$1"
    local dest="$2"

    if [[ -d "$dest/.git" ]]; then
        skip "$(basename "$dest") already installed."
        return
    fi

    step "Installing $(basename "$dest")"

    git clone --depth=1 "$url" "$dest"

    success "$(basename "$dest") installed."
}

download() {

    local url="$1"
    local output="$2"

    curl -L "$url" -o "$output"
}
