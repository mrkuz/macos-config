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
    brew upgrade --dry-run
}

function upgrade() {
    darwin-rebuild switch -v --flake ".#$1"
    brew upgrade
    brew bundle dump -f
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
        [[ $# -ne 2 ]] && usage
        upgrade "$2"
        ;;
    "clean")
        clean
        ;;
    *)
        usage
        ;;
esac
