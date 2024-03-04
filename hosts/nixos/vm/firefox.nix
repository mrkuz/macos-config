{ config, lib, pkgs, nixpkgs, self, options, ... }:
let
  program = "${pkgs.firefox-devedition}/bin/firefox-devedition";
in {
  modules = {
    nix.enable = false;
    minimize.enable = false;
    qemuGuest = {
      autoLogin = true;
      dhcp = true;
      graphics = true;
      opengl = true;
      socketVmnet = true;
      user = self.vars.primaryUser;
    };
  };

  services.cage = {
    inherit program;
    enable = false;
    user = self.vars.primaryUser;
  };

  services.xserver = {
    enable = true;
    displayManager = {
      lightdm = {
        enable = config.services.xserver.enable;
        autoLogin.timeout = 0;
      };
      defaultSession = "default";
      session = [
        {
          manage = "desktop";
          name = "default";
          start = ''
            ${program} &
            WINDOW=$(${pkgs.xdotool}/bin/xdotool search --sync --onlyvisible --pid $!)
            ${pkgs.xdotool}/bin/xdotool windowsize $WINDOW 100% 100%
            waitPID=$!
          '';
        }
      ];
    };
  };
}
