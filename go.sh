#!/usr/bin/env bash

set -e

if [[ ! -f "flake.nix" ]]; then
  echo "Script must be executed from config root directory"
  exit 1
fi

USERS_DIR="$(dirname $HOME)"
SRC_DIR="src"
KEEP_GENERATIONS="1"

# Colors

BLACK="\e[0;30m"
RED="\e[0;31m"
GREEN="\e[0;32m"
YELLOW="\e[0;33m"
BLUE="\e[0;34m"
MAGENTA="\e[0;35m"
CYAN="\e[0;36m"
LIGHT_GRAY="\e[0;37m"
DARK_GRAY="\e[0;90m"
LIGHT_RED="\e[0;91m"
LIGHT_GREEN="\e[0;92m"
LIGHT_YELLOW="\e[0;93m"
LIGHT_BLUE="\e[0;94m"
LIGHT_MAGENTA="\e[0;95m"
LIGHT_CYAN="\e[0;96m"
WHITE="\e[0;97m"
RESET="\e[0m"

function usage() {
    echo "
Usage: $0 COMMAND

Commands:

- setup
- pull
- update
- rebuild HOST
- upgrade HOST
- clean
"
    exit 1
}

function info() {
    echo -e "\n${BLUE}>>>${RESET} $1\n"
}

function pause() {
    echo -e "\n${YELLOW}>>>${RESET} Press any key to continue..."
    read -n1
}

function setup() {
    info "Launching Linux builder"
    sudo launchctl start org.nixos.linux-builder
}

function pull() {
    info "Pulling $1"

    pushd . > /dev/null
    cd "$SRC_DIR/$1"

    git branch
    git tag -f "pull/previous"
    git pull
    git tag -f "pull/$(date +%Y%m%d)"
    pause

    popd
}

function update() {
    info "Updating flake inputs"
    nix flake update
    git diff flake.lock
    pause

    info "Updating niv dependencies"
    niv update
    git diff nix/sources.json
    pause

    info "Updating brew"
    brew update
    pause

    info "Outdated brew packages"
    brew outdated --greedy
    pause

    info "Outdated Mac App Store packages"
    mas outdated
    pause
}

function rebuild() {
    info "Rebuild and switch"
    darwin-rebuild switch --keep-going  -v --flake ".#$1"
    current=$(HOME=/var/root sudo nix-env --profile "/nix/var/nix/profiles/system" --list-generations | awk '/current/{print $1}')
    prev=$((current - 1))
    if [[ -e "/nix/var/nix/profiles/system-$current-link" ]]; then
        if [[ -e "/nix/var/nix/profiles/system-$prev-link" ]]; then
            nvd diff /nix/var/nix/profiles/system-{$prev,$current}-link/
        fi
    fi
}

function upgrade() {
    rebuild "$1"

    info "Upgrading brew packages"
    brew upgrade --greedy
    brew bundle dump -f

    info "Upgrading Mac App Store packages"
    mas upgrade
}

function clean() {
    info "Deleting up old generations"
    HOME=/var/root sudo nix-env --delete-generations +"$KEEP_GENERATIONS" --profile /nix/var/nix/profiles/system

    for path in $USERS_DIR/*; do
        user=${path##*/}
        if [[ -d "$USERS_DIR/$user/.local/state/nix/profiles/home-manager" ]]; then
            HOME=/var/root sudo nix-env --delete-generations +"$KEEP_GENERATIONS" --profile "$USERS_DIR/$user/.local/state/nix/profiles/home-manager"
        fi
    done
    pause

    info "Collecting garbage"
    HOME=/var/root sudo nix-collect-garbage
    pause

    info "Nix store roots"
    nix-store --gc --print-roots | egrep -v "\{censored|lsof\}" | column -t | sort -k3 -k1
    pause

    info "Remove unused brew dependencies"
    brew autoremove
    pause

    info "Clean up brew cache"
    brew cleanup --prune=all
}

case "$1" in
    "setup")
        setup
        ;;
    "pull")
        pull "home-manager"
        pull "nix-darwin"
        pull "nixpkgs"
        ;;
    "update")
        update
        ;;
    "rebuild")
        if [[ $# -eq 1 ]]; then
            rebuild $(hostname -s)
        elif [[ $# -eq 2 ]]; then
            rebuild "$2"
        else
            usage
        fi
        ;;
    "upgrade")
        if [[ $# -eq 1 ]]; then
            upgrade $(hostname -s)
        elif [[ $# -eq 2 ]]; then
            upgrade "$2"
        else
            usage
        fi
        ;;
    "clean")
        clean
        ;;
    *)
        usage
        ;;
esac
