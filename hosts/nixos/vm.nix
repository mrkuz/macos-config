{ pkgs, lib, nixpkgs, self, ... }:
let
  # See: https://unix.stackexchange.com/questions/16578/resizable-serial-console-window
  resize = pkgs.writeScriptBin "resize" ''
    if [ -e /dev/tty ]; then
      old=$(stty -g)
      stty raw -echo min 0 time 5
      printf '\033[18t' > /dev/tty
      IFS=';t' read -r _ rows cols _ < /dev/tty
      stty "$old"
      stty cols "$cols" rows "$rows"
    fi
  '';
in {
  imports = [
    ../../profiles/nixos/minimal.nix
  ];

  modules = {
    nix.enable = true;
  };

  environment = {
    systemPackages = with pkgs; [ htop resize ];
    loginShellInit = ''
      "${resize}/bin/resize";
      export TERM=screen-256color
    '';
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

  networking = {
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
  };

  security.sudo = {
    execWheelOnly = true;
    wheelNeedsPassword = false;
  };

  services.getty = {
    autologinUser = self.vars.primaryUser;
    helpLine = ''

      Type 'Ctrl-a c' to switch to the QEMU console
    '';
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
      hashedPassword = "*";
      extraGroups = [ "wheel" ];
      openssh.authorizedKeys.keyFiles = [
        ../../users/darwin/markus/files/id_rsa.pub
      ];
    };
    users.root = {
      hashedPassword = "*";
    };
  };

  virtualisation = {
    diskImage = null;
    cores = 2;
    memorySize = 4096;
    forwardPorts = [
      # openssh
      { from = "host"; guest.port = 22; host.port = 2201; }
    ];
    graphics = false;
  };
}
