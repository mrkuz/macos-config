{ config, pkgs, lib, ... }:
with lib;
let
  cfg = config.modules.emacs;
in
{
  options.modules.emacs = {
    enable = mkOption {
      default = false;
      type = types.bool;
    };
  };

  config = mkIf cfg.enable {
    home = {
      packages = with pkgs; [
        emacs-unstable
      ];
    };

    launchd = {
      enable = true;
      agents = {
        emacs = {
          enable = true;
          config = {
            ProgramArguments = [ "${pkgs.emacs-unstable}/bin/emacs" "--daemon=default" ];
            RunAtLoad = true;
          };
        };
      };
    };
  };
}
