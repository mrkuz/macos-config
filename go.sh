#!/usr/bin/env bash

set -e

if [[ ! -f "flake.nix" ]]; then
  echo "Script must be executed from config root directory"
  exit 1
fi

SRC_DIR="/Users/markus/src/nix/"
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

function pull() {
    info "Pulling $1"

    pushd . > /dev/null
    cd "$SRC_DIR/$1"

    git branch
    git tag -f previous
    git pull
    pause

    popd
}

function update() {
    info "Updating flake inputs"
    nix flake update
    git diff flake.lock
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
    darwin-rebuild switch -v --flake ".#$1"
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

    for path in /Users/*; do
        user=${path##*/}
        if [[ -d "/Users/$user/.local/state/nix/profiles/home-manager" ]]; then
            HOME=/var/root sudo nix-env --delete-generations +"$KEEP_GENERATIONS" --profile "/Users/$user/.local/state/nix/profiles/home-manager"
        fi
    done
    pause

    info "Collecting garbate"
    HOME=/var/root sudo nix-collect-garbage
    pause

    info "Nix store roots"
    nix-store --gc --print-roots | grep -v {censored} | column -t | sort -k3 -k1
    pause
}

case "$1" in
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
            rebuild $(hostname)
        elif [[ $# -eq 2 ]]; then
            rebuild "$2"
        else
            usage
        fi
        ;;
    "upgrade")
        if [[ $# -eq 1 ]]; then
            upgrade $(hostname)
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

