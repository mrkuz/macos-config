{ config, lib, pkgs, pkgsStable, ... }:
with lib;
let
  cfg = config.modules.alacritty;
in
{
  options.modules.alacritty = {
    enable = mkOption {
      default = false;
      type = types.bool;
    };
    shell = mkOption {
      default = "${pkgs.zsh}/bin/zsh";
      type = types.str;
    };
  };

  config = mkIf cfg.enable {
    programs.alacritty = {
      enable = true;
      settings = {
        terminal.shell = cfg.shell;
        general.import = [
          "${pkgs.alacritty-theme}/share/alacritty-theme/solarized_dark.toml"
        ];
        window = {
          padding = { x = 10; y = 10; };
          # opacity = 0.9;
          # blur = true;
        };
      };
    };
  };
}
