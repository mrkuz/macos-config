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
      address = "192.168.105.101";
      prefixLength = 24;
    }
  ];

  services.journald.console = "/dev/console";

  virtualisation.docker = {
    enable = true;
    listenOptions = [ "/run/docker.sock" "0.0.0.0:2375" ];
  };
}
