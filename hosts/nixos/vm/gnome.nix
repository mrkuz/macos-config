{ config, lib, pkgs, nixpkgs, self, options, ... }:
{
  modules = {
    nix.enable = true;
    minimize.enable = false;
    qemuGuest = {
      dhcp = true;
      graphics = true;
      socketVmnet = true;
      user = self.vars.primaryUser;
    };
  };

  programs.gnome-terminal.enable = true;

  services.xserver = {
    enable = true;
    desktopManager.gnome.enable = true;
    displayManager.gdm.enable = true;
  };
  services.gnome.core-utilities.enable = false;

  users.users."${self.vars.primaryUser}" = {
    password = self.vars.primaryUser;
  };
}
