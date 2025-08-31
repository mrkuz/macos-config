{ config, lib, pkgs, pkgsStable, ... }:
with lib;
let
  cfg = config.modules.fish;
in
{
  options.modules.fish = {
    enable = mkOption {
      default = false;
      type = types.bool;
    };
    extraInit = mkOption {
      type = types.lines;
      default = "";
    };
  };

  config = mkIf cfg.enable {
    home.shell.enableFishIntegration = true;
    programs.fish = {
      enable = true;
      plugins = [
        {
          name = "pure";
          src = pkgs.fishPlugins.pure.src;
        }
      ];
      shellAbbrs = import ./shell/abbr.nix;
      interactiveShellInit = ''
        set -U fish_greeting
        set -U pure_symbol_prompt ">"
        set -U pure_color_mute "brgreen"
        set -U pure_enable_nixdevshell true
        set -U pure_enable_single_line_prompt true
        set -U fish_color_autosuggestion 586e75
        fish_add_path $HOME/bin
        fish_add_path $HOME/.local/bin/

        ${cfg.extraInit or ""}
      '';
    };
  };
}
