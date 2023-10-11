#!/usr/bin/env bash

set -e

if [[ ! -f "flake.nix" ]]; then
  echo "Script must be executed from config root directory"
  exit 1
fi

KEEP_GENERATIONS="1"

function usage() {
    echo "
Usage: $0 COMMAND

Commands:

- update
- upgrade HOST
- clean
"
    exit 1
}

function update() {
    nix flake update
    git diff flake.lock

    brew update
    brew outdated --greedy

    mas outdated
}

function upgrade() {
    darwin-rebuild switch -v --flake ".#$1"

    brew upgrade --greedy
    brew bundle dump -f

    mas upgrade
}

function clean() {
    HOME=/var/root sudo nix-env --delete-generations +"$KEEP_GENERATIONS" --profile /nix/var/nix/profiles/system

    for path in /Users/*; do
        user=${path##*/}
        if [[ -d "/Users/$user/.local/state/nix/profiles/home-manager" ]]; then
            HOME=/var/root sudo nix-env --delete-generations +"$KEEP_GENERATIONS" --profile "/Users/$user/.local/state/nix/profiles/home-manager"
        fi
    done
    
    HOME=/var/root sudo nix-collect-garbage

    echo
    nix-store --gc --print-roots | grep -v {censored} | column -t | sort -k3 -k1
}

case "$1" in
    "update")
        update
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
