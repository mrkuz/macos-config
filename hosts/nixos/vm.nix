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
    hostName = "nixos-demo";
    dhcpcd.enable = false;
    useDHCP = false;
    defaultGateway = "10.0.2.2";
    nameservers = [ "10.0.2.3" ];
    interfaces.eth0.ipv4.addresses = [
      {
        address = "10.0.2.15";
        prefixLength = 24;
      }
    ];
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

  security.sudo = {
    execWheelOnly = true;
    wheelNeedsPassword = false;
  };

  services.getty = {
    autologinUser = self.vars.primaryUser;
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

  systemd.network = {
    enable = false;
    networks = {
      "default" = {
        matchConfig = {
          Name = "eth0";
        };
        address = [
          "10.0.2.15/24"
        ];
        DHCP = "no";
        gateway = [ "10.0.2.2" ];
        dns = [ "10.0.2.3" ];
      };
    };
    # Speed up boot
    wait-online.enable = false;
  };

  users = {
    allowNoPasswordLogin = true;
    mutableUsers = false;
    users."${self.vars.primaryUser}" = {
      isNormalUser = true;
      # shell = pkgs.fish;
      hashedPassword = "*";
      extraGroups = [ "wheel" "docker" ];
      openssh.authorizedKeys.keyFiles = [
        ../../users/darwin/markus/files/id_rsa.pub
      ];
    };
    users.root = {
      hashedPassword = "*";
    };
  };

  # home-manager.users."${self.vars.primaryUser}" = ./vm/home.nix;

  virtualisation.docker = {
    enable = false;
    listenOptions = [ "/run/docker.sock" "0.0.0.0:2375" ];
  };
}
