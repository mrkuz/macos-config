{ config, lib, pkgs, nixpkgs, self, options, ... }:
{
  modules = {
    nix.enable = true;
    minimize.enable = false;
    qemuGuest = {
      autoLogin = true;
      dhcp = true;
      graphics = true;
      socketVmnet = true;
      user = self.vars.primaryUser;
      opengl = true;
    };
  };

  #documentation = {
  #  enable = true;
  #  doc.enable = false;
  #  info.enable = false;
  #  man.enable = true;
  #  nixos.enable = true;
  #};

  environment.systemPackages = with pkgs; [
    pantheon.elementary-terminal
  ];

  services.pantheon.apps.enable = false;

  services.xserver = {
    enable = true;
    excludePackages = [ pkgs.xterm ];
    desktopManager.pantheon.enable = true;
  };

  users.users."${self.vars.primaryUser}" = {
    password = self.vars.primaryUser;
  };
}
