{ config, pkgs, lib, nixpkgs, self, ... }:
with lib;
let
  cfg = config.modules.nix;
in
{
  options.modules.nix = {
    enable = mkOption {
      default = false;
      type = types.bool;
    };
  };

  config = mkIf cfg.enable {
    environment.extraInit = ''
      export NIX_PATH="nixpkgs=${nixpkgs}"
    '';

    environment.etc = {
      "nix/current".source = self;
      "nix/nixpkgs".source = nixpkgs;
    };

    environment.systemPackages = with pkgs; [
      niv
      nix-index
    ];

    nix = {
      # Use local nixpkgs
      registry.nixpkgs = {
        from = {
          id = "nixpkgs";
          type = "indirect";
        };
        to = lib.mkForce {
          path = "${nixpkgs}";
          type = "path";
        };
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

    services.nix-daemon.enable = true;
  };
}
