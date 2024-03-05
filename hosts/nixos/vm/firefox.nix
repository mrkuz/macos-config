{ config, lib, pkgs, nixpkgs, self, options, ... }:
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
      user = self.vars.primaryUser;
    };
    kiosk = {
      enable = true;
      program = "${pkgs.firefox-devedition}/bin/firefox-devedition";
      user = self.vars.primaryUser;
    };
  };
}
