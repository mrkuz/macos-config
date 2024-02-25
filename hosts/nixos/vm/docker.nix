{ config, lib, pkgs, nixpkgs, self, ... }:
{
  modules = {
    nix.enable = false;
    minimize.enable = true;
    qemuGuest = {
      noLogin = true;
      sshd = true;
      vmnet = true;
    };
  };

  networking.firewall.enable = false;
  networking.interfaces.eth0.ipv4.addresses = [
    {
      address = "192.168.64.10";
      prefixLength = 24;
    }
  ];

  users.users.root.openssh.authorizedKeys.keyFiles = [
    ../../../users/darwin/markus/files/id_rsa.pub
  ];

  virtualisation.docker = {
    enable = true;
    listenOptions = [ "/run/docker.sock" "0.0.0.0:2375" ];
  };
}
