{ config, lib, pkgs, nixpkgs, self, versions, systemName, ... }:
with lib;
let
  cfg = config.modules.nix;
in
{
  imports = [ ../common/nix.nix ];
  config = mkIf cfg.enable {
    environment.etc = {
      "nixos/configuration.nix".text = ''
        nix = {
          nixPath = [ "nixpkgs=${nixpkgs}" ];
        };
        system.name = "${systemName}";
        system.stateVersion = "${versions.nixos.stateVersion}";
        system.configurationRevision = "${versions.rev}";
      '';

      # Provide compatibility layer for non-flake utils
      "nixos/compat/default.nix".text = ''
        { ... }:
        let
          nixpkgs = import ${nixpkgs} {};
        in
          nixpkgs
      '';
      "nixos/compat/nixos/default.nix".text = ''
        { ... }:
        let
          current = import ${self};
        in
          current.nixosConfigurations."${systemName}"
      '';
    };

    environment.systemPackages = with pkgs; [
      nixos-option
    ];

    nix = {
      settings = {
        substituters = [
          # "https://cache.nixos.org/"
          "https://nix-community.cachix.org"
        ];
        trusted-public-keys = [
          # "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
          "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        ];
      };
    };
  };
}
