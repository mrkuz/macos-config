{ config, lib, pkgs, ... }:
with lib;
let
  cfg = config.modules.emacs;
  emacsPkg = ((pkgs.emacsPackagesFor pkgs.emacs-unstable).emacsWithPackages (epkgs: [ epkgs.vterm ]));
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
      packages = [ emacsPkg ];
    };

    launchd = {
      enable = true;
      agents = {
        emacs = {
          enable = true;
          config = {
            ProgramArguments = [ "${emacsPkg}/bin/emacs" "--daemon=default" ];
            RunAtLoad = true;
          };
        };
      };
    };
  };
}
