{ config, lib, pkgs, nixpkgs, self, ... }:
{
  modules = {
    minimize.enable = true;
    nix.enable = true;
  };

  environment.etc = {
    "ssh/ssh_host_rsa_key" = {
      mode = "0600";
      source = ./vm/files/ssh_host_rsa_key;
    };
    "ssh/ssh_host_rsa_key.pub" = {
      mode = "0644";
      source = ./vm/files/ssh_host_rsa_key.pub;
    };
    "ssh/ssh_host_ed25519_key" = {
      mode = "0600";
      source = ./vm/files/ssh_host_ed25519_key;
    };
    "ssh/ssh_host_ed25519_key.pub" = {
      mode = "0644";
      source = ./vm/files/ssh_host_ed25519_key.pub;
    };
  };

  environment.systemPackages = with pkgs; [ htop ];

  networking = {
    # defaultGateway = "192.168.64.1";
    # nameservers = [ "192.168.64.1" ];
    # interfaces.eth0.ipv4.addresses = [
    #   {
    #     address = "192.168.64.10";
    #     prefixLength = 24;
    #   }
    # ];
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

  # programs.fish.enable = true;

  services.getty = {
    # loginProgram = "${pkgs.coreutils-full}/bin/sleep";
    # loginOptions = "infinity";
    # extraArgs = [ "--skip-login" ];
  };

  services.openssh = {
    enable = false;
    openFirewall = true;
    settings = {
      StrictModes = false;
      PermitRootLogin = "no";
      PasswordAuthentication = false;
      AllowUsers = [ self.vars.primaryUser ];
      X11Forwarding = true;
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

  users = {
    users."${self.vars.primaryUser}" = {
      # shell = pkgs.fish;
      openssh.authorizedKeys.keyFiles = [
        ../../users/darwin/markus/files/id_rsa.pub
      ];
    };
  };

  # home-manager.users."${self.vars.primaryUser}" = ./vm/home.nix;

  virtualisation = {
    # forwardPorts = [
      # openssh
      # { from = "host"; host.port = 2201; guest.port = 22; }
      # docker
      # { from = "host"; host.port = 2375; guest.port = 2375; }
      # k3s
      # { from = "host"; host.port = 6443; guest.port = 6443; }
    # ];
    #
    # qemu.networkingOptions = [
    #   "-device virtio-net-device,netdev=net.0"
    #   "-netdev vmnet-shared,id=net.0,\${QEMU_NET_OPTS:+,$QEMU_NET_OPTS}"
    # ];

    docker = {
      enable = false;
      listenOptions = [ "/run/docker.sock" "0.0.0.0:2375" ];
    };
  };
}
