{
  config,
  lib,
  pkgs,
  pkgsStable,
  ...
}:
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
        font = {
          normal = {
            family = "SFMono Nerd Font";
            style = "Light";
          };
          bold = {
            family = "SFMono Nerd Font";
            style = "Regular";
          };
          size = 14.0;
          offset = {
            x = 0;
            y = 4;
          };
        };
        window = {
          title = "Alacritty";
          dynamic_title = false;
          padding = {
            x = 8;
            y = 8;
          };
          dimensions = {
            columns = 120;
            lines = 40;
          };
        };
      };
    };
  };
}
