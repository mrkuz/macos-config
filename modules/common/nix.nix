{ config, lib, pkgs, nixpkgs, self, ... }:
with lib;
let
  cfg = config.modules.nix;
  mkRegistry = id: branch: {
    from = {
      inherit id;
      type = "indirect";
    };
    to = {
      type = "github";
      owner = "NixOS";
      repo = "nixpkgs";
      ref = branch;
    };
  };
in
{
  options.modules.nix = {
    enable = mkOption {
      default = false;
      type = types.bool;
    };
  };

  config = mkIf cfg.enable {
    environment.etc = {
      "nix/current".source = self;
      "nix/nixpkgs".source = nixpkgs;
    };

    environment.extraInit = ''
      export NIX_PATH="nixpkgs=${nixpkgs}"
    '';

    nix = {
      # Use local nixpkgs
      registry = {
        nixpkgs = {
          from = {
            id = "nixpkgs";
            type = "indirect";
          };
          to = lib.mkForce {
            path = "${nixpkgs}";
            type = "path";
          };
        };
        nixpkgs-unstable = mkRegistry "nixpkgs-unstable" "nixpkgs-unstable";
        nixos-stable = mkRegistry "nixos-stable" "nixos-${self.vars.nixos.stableVersion}";
        nixos-unstable = mkRegistry "nixos-unstable" "nixos-unstable";
      };
      settings = {
        experimental-features = "nix-command flakes";
        narinfo-cache-positive-ttl = 86400;
        keep-outputs = true;
        keep-derivations = true;
        auto-optimise-store = true;
        sandbox = true;
      };
    };
  };
}
