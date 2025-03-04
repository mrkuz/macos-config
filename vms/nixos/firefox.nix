{ config, lib, pkgs, nixpkgs, vars, options, ... }:
{
  modules = {
    nix.enable = false;
    minimize.enable = false;
    qemuGuest = {
      autoLogin = true;
      dhcp = true;
      graphics = true;
      opengl = true;
      socketVmnet = true;
      user = vars.primaryUser;
    };
    kiosk = {
      enable = true;
      program = "${pkgs.firefox-devedition}/bin/firefox-devedition";
      user = vars.primaryUser;
    };
  };

  nix.enable = false;
}
