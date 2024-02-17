{ pkgs, lib, nixpkgs, self, ... }:
{
  imports = [
    ../../profiles/nixos/minimal.nix
  ];

  modules = {
    nix.enable = true;
  };

  environment = {
    systemPackages = with pkgs; [ xterm htop ];
    loginShellInit = ''
      eval $(resize)
      export TERM=screen-256color
    '';
  };

  networking = {
    dhcpcd.enable = false;
    useDHCP = false;
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

  systemd.network = {
    enable = true;
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
    };
    users.root = {
      hashedPassword = "*";
    };
  };

  virtualisation = {
    graphics = false;
    diskImage = null;
    cores = 2;
    memorySize = 4096;
  };
}
