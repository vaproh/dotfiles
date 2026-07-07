#!/usr/bin/env bash

# ==========================
# Colors
# ==========================

RESET='\033[0m'
BOLD='\033[1m'
DIM='\033[2m'

BLACK='\033[30m'
RED='\033[31m'
GREEN='\033[32m'
YELLOW='\033[33m'
BLUE='\033[34m'
MAGENTA='\033[35m'
CYAN='\033[36m'
WHITE='\033[37m'
GRAY='\033[90m'

# ==========================
# Logging
# ==========================

header() {
    printf "\n${BOLD}${CYAN}"
    printf "╔══════════════════════════════════════════════════════╗\n"
    printf "║ %-52s ║\n" "$1"
    printf "╚══════════════════════════════════════════════════════╝\n"
    printf "${RESET}\n"
}

section() {
    printf "\n${BOLD}${MAGENTA}%s${RESET}\n" "$1"
    printf "${MAGENTA}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}\n"
}

step() {
    printf "\n${CYAN}➜${RESET} %s\n" "$1"
}

info() {
    printf "${BLUE}[*]${RESET} %s\n" "$1"
}

success() {
    printf "${GREEN}[✓]${RESET} %s\n" "$1"
}

skip() {
    printf "${YELLOW}[↷]${RESET} %s\n" "$1"
}

warn() {
    printf "${YELLOW}[!]${RESET} %s\n" "$1"
}

die() {
    printf "${RED}[✗]${RESET} %s\n" "$1"
    exit 1
}

divider() {
    printf "${DIM}──────────────────────────────────────────────────────${RESET}\n"
}

# ==========================
# Utilities
# ==========================

command_exists() {
    command -v "$1" >/dev/null 2>&1
}

directory_exists() {
    [[ -d "$1" ]]
}

file_exists() {
    [[ -f "$1" ]]
}

ensure_dir() {
    mkdir -p "$1"
}

make_executable() {
    chmod +x "$@"
}

run() {
    info "$*"
    "$@"
}

confirm() {
    read -rp "$1 [y/N]: " ans

    case "$ans" in
        y|Y|yes|YES)
            return 0
            ;;
        *)
            return 1
            ;;
    esac
}

refresh_fonts() {
    fc-cache -fv
}

has_internet() {
    ping -c 1 archlinux.org >/dev/null 2>&1
}

check() {

    local name="$1"
    shift

    printf "%-40s" "$name"

    if "$@" >/dev/null 2>&1; then
        printf "${GREEN}✓${RESET}\n"
    else
        printf "${RED}✗${RESET}\n"
    fi
}
