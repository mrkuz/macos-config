{ config, lib, pkgs, nixpkgs, self, ... }:
{
  networking = {
    firewall = {
      enable = true;
      allowedTCPPorts = [
        # docker
        2375
        # k3s
        6443
      ];
    };
  };

  services.k3s.enable = false;

  services.cage = {
    enable = false;
    program = "${pkgs.xterm}/bin/xterm";
    user = self.vars.primaryUser;
  };

  services.xserver = {
    enable = false;
    displayManager = {
      lightdm = {
        enable = config.services.xserver.enable;
        autoLogin.timeout = 0;
      };
      autoLogin.user = self.vars.primaryUser;
      defaultSession = "default";
      session = [
        {
          manage = "desktop";
          name = "default";
          start = ''
            ${pkgs.xterm}/bin/xterm &
            WINDOW=$(${pkgs.xdotool}/bin/xdotool search --sync --onlyvisible --pid $!)
            ${pkgs.xdotool}/bin/xdotool windowsize $WINDOW 100% 100%
            waitPID=$!
          '';
        }
      ];
    };
  };

  virtualisation = {
    # forwardPorts = [
      # openssh
      # { from = "host"; host.port = 2201; guest.port = 22; }
      # docker
      # { from = "host"; host.port = 2375; guest.port = 2375; }
      # k3s
      # { from = "host"; host.port = 6443; guest.port = 6443; }
    # ];

    docker = {
      enable = false;
      listenOptions = [ "/run/docker.sock" "0.0.0.0:2375" ];
    };
  };
}
