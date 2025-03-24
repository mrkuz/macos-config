{ config, lib, pkgs, ... }:
with lib;
let
  cfg = config.modules.emacs;
  emacsPkg = ((pkgs.emacsPackagesFor pkgs.emacs-plus).emacsWithPackages (epkgs: with epkgs; [
    vterm
    treesit-grammars.with-all-grammars
  ]));
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
        emacsPkg
        # Dependencies
        pandoc
        # Dependencies: Lua
        luajitPackages.luacheck
        luajitPackages.lua-lsp
      ];
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
