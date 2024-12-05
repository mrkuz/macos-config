{ config, lib, pkgs, pkgsStable, ... }:
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
      type = types.str;
    };
  };

  config = mkIf cfg.enable {
    programs.kitty = {
      enable = true;
      package = pkgs.kitty;
      shellIntegration = {
        enableFishIntegration = cfg.enableFishIntegration;
        mode = "no-cursor";
      };
      themeFile = "Solarized_Dark_-_Patched";
      settings = {
        cursor_shape = "block";
        cursor_blink_interval = 0;
        copy_on_select = "clipboard";
        mouse_hide_wait = 0;
        shell = cfg.shell;
        strip_trailing_spaces = "smart";
        macos_quit_when_last_window_closed = true;
        # sync_to_monitor = false;
        wayland_enable_ime = false;
      };
    };
  };
}
