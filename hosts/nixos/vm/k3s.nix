{ config, lib, pkgs, nixpkgs, self, ... }:
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

  services.k3s = {
    enable = true;
  };
}
