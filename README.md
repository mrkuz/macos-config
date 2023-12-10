# Installation

1. Install Nix

```shell
sh <(curl -L https://nixos.org/nix/install)
```

2. Clone repo

```shell
nix shell --extra-experimental-features 'nix-command flakes' nixpkgs#git

mkdir ~/etc/
cd ~/etc/
git clone <TODO>
```

3. Install nix-darwin

```shell
nix run --extra-experimental-features 'nix-command flakes' nix-darwin -- switch --flake  .
darwin-rebuild switch --flake .
```

# Let's go

## ./go.sh update

Updates flake inputs, brew and shows outdated brew and App Store packages.

## ./go.sh upgrade

Runs `darwin-rebuild` and upgrades all brew and App Store packages.

## ./go.sh clean

Deletes old generations, removes unused brew dependencies and clean brew cache.

# Appendix A: Package installation

1. If it is offical Apple software or there are no other installation options -> App Store
2. If it is proprietary software, or distributed as DMG -> homebrew
3. Else -> nix
