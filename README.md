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
