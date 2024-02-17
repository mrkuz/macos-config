{ pkgs, lib, nixpkgs, self, ... }:
{
  imports = [
    ../../profiles/nixos/minimal.nix
  ];

  modules = {
    nix.enable = true;
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
