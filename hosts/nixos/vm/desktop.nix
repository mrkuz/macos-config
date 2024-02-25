{ config, lib, pkgs, nixpkgs, self, ... }:
{
  modules = {
    nix.enable = true;
    minimize.enable = false;
    qemuGuest = {
      user = self.vars.primaryUser;
      dhcp = false;
      sshd = true;
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
    openssh.authorizedKeys.keyFiles = [
      ../../../users/darwin/markus/files/id_rsa.pub
    ];
  };

  virtualisation = {
    graphics = lib.mkForce true;
    forwardPorts = [
      { from = "host"; host.port = 2201; guest.port = 22; }
    ];
  };
}
