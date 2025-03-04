{ config, lib, pkgs, nixpkgs, vars, options, ... }:
{
  modules = {
    nix.enable = true;
    minimize.enable = false;
    qemuGuest = {
      dhcp = true;
      graphics = true;
      opengl = true;
      socketVmnet = true;
      user = vars.primaryUser;
    };
  };

  programs.gnome-terminal.enable = true;
  services.gnome.core-utilities.enable = false;

  services.xserver = {
    enable = true;
    desktopManager.gnome.enable = true;
    displayManager.gdm.enable = true;
  };

  users.users."${vars.primaryUser}" = {
    password = vars.primaryUser;
  };
}
