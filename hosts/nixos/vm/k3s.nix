{ config, lib, pkgs, nixpkgs, ... }:
{
  modules = {
    nix.enable = false;
    minimize.enable = true;
    qemuGuest = {
      noLogin = true;
      socketVmnet = true;
      sshd = true;
    };
  };

  networking.firewall.enable = false;
  networking.interfaces.eth0.ipv4.addresses = [
    {
      address = "192.168.105.102";
      prefixLength = 24;
    }
  ];

  services.journald.console = "/dev/console";

  services.k3s = {
    enable = true;
    package = pkgs.k3s-bin;
  };
}
