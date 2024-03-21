{ config, lib, pkgs, nixpkgs, ... }:
{
  modules = {
    nix.enable = false;
    minimize = {
      enable = true;
      noLogin = true;
      noNix = true;
    };
    qemuGuest = {
      socketVmnet = true;
      sshd = true;
    };
  };

  networking.firewall.enable = false;
  networking.interfaces.eth0.ipv4.addresses = [
    {
      address = "192.168.105.101";
      prefixLength = 24;
    }
  ];

  virtualisation.docker = {
    enable = true;
    listenOptions = [ "/run/docker.sock" "0.0.0.0:2375" ];
  };
}
