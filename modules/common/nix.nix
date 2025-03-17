{ config, lib, pkgs, nixpkgs, self, versions, ... }:
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

    environment.systemPackages = with pkgs; [
      nil
      niv
      # nix-index
      # nix-index-update
      nvd
    ];

    nix = {
      channel.enable = false;
      nixPath = [ "nixpkgs=${nixpkgs}" ];
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
        nixos-stable = mkRegistry "nixos-stable" "nixos-${versions.nixos.stableVersion}";
        nixos-unstable = mkRegistry "nixos-unstable" "nixos-unstable";
      };
      optimise.automatic = true;
      settings = {
        experimental-features = "nix-command flakes";
        narinfo-cache-positive-ttl = 604800;
        keep-outputs = true;
        keep-derivations = true;
        # sandbox = true;
      };
    };

    nixpkgs.flake = {
      # We take care of this on our own
      setNixPath = false;
      setFlakeRegistry = false;
    };
  };
}
