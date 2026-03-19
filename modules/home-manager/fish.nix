{
  config,
  lib,
  pkgs,
  pkgsStable,
  ...
}:
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
      shellAbbrs = import ./shell/abbr.nix;
      interactiveShellInit = ''
        set -U fish_greeting
        set -U fish_color_autosuggestion 586e75
        fish_add_path $HOME/bin
        fish_add_path $HOME/.local/bin/

        ${cfg.extraInit or ""}
      '';
    };
  };
}
