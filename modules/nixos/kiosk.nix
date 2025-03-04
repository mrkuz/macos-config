{ config, lib, pkgs, nixpkgs, ... }:
with lib;
let
  cfg = config.modules.kiosk;
in {
  options.modules.kiosk = {
    enable = mkOption {
      default = false;
      type = types.bool;
    };
    wayland = mkOption {
      default = false;
      type = types.bool;
    };
    program = mkOption {
      default = null;
      type = types.str;
    };
    user = mkOption {
      default = null;
      type = types.str;
    };
  };

  config = mkIf cfg.enable {
    services.cage = {
      enable = cfg.wayland;
      user = cfg.user;
      program = cfg.program;
    };

    services.displayManager = {
      defaultSession = "default";
      autoLogin.user = cfg.user;
    };

    services.xserver = {
      enable = !cfg.wayland;
      displayManager = {
        lightdm = {
          enable = !cfg.wayland;
          autoLogin.timeout = 0;
        };
        session = [
          {
            manage = "desktop";
            name = "default";
            start = ''
              ${cfg.program} &
              WINDOW=$(${pkgs.xdotool}/bin/xdotool search --sync --onlyvisible --pid $!)
              ${pkgs.xdotool}/bin/xdotool windowsize $WINDOW 100% 100%
              waitPID=$!
            '';
          }
        ];
      };
    };
  };
}
