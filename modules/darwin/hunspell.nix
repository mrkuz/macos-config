{ config, lib, pkgs, nixpkgs, ... }:
with lib;
let
  cfg = config.modules.hunspell;
in
{
  options.modules.hunspell = {
    enable = mkOption {
      default = false;
      type = types.bool;
    };
  };

  config = mkIf cfg.enable {
    environment.pathsToLink = [ "/share/hunspell" ];

    environment.systemPackages = with pkgs; [
      hunspell
      hunspellDicts.de_AT
      hunspellDicts.en_US
    ];
  };
}
