{ config, pkgs, lib, ... }:
with lib;
let
  cfg = config.modules.kitty;
in
{
  options.modules.kitty = {
    enable = mkOption {
      default = false;
      type = types.bool;
    };
    enableFishIntegration = mkOption {
      default = false;
      type = types.bool;
    };
    shell = mkOption {
      default = "${pkgs.zsh}/bin/zsh";
      type = types.string;
    };
  };

  config = mkIf cfg.enable {
    programs.kitty = {
      enable = true;
      shellIntegration = {
        enableFishIntegration = cfg.enableFishIntegration;
        mode = "no-cursor";
      };
      theme = "Solarized Dark - Patched";
      font = {
        name = "SF Mono";
        size = 14;
      };
      settings = {
        cursor_shape = "block";
        cursor_blink_interval = 0;
        copy_on_select = "clipboard";
        mouse_hide_wait = 0;
        shell = cfg.shell;
        strip_trailing_spaces = "smart";
      };
    };
  };
}
