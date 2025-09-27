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

  services.desktopManager.gnome.enable = true;
  services.displayManager.gdm.enable = true;
  services.gnome.core-apps.enable = false;

  users.users."${vars.primaryUser}" = {
    password = vars.primaryUser;
  };
}
