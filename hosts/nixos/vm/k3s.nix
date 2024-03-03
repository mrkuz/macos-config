{ config, lib, pkgs, nixpkgs, self, ... }:
{
  modules = {
    nix.enable = false;
    minimize.enable = true;
    qemuGuest = {
      noLogin = true;
      sshd = true;
      socketVmnet = true;
    };
  };

  networking.firewall.enable = false;
  networking.interfaces.eth0.ipv4.addresses = [
    {
      address = "192.168.105.102";
      prefixLength = 24;
    }
  ];

  users.users.root.openssh.authorizedKeys.keyFiles = [
    ../../../users/darwin/markus/files/id_rsa.pub
  ];

  services.k3s = {
    enable = true;
  };
}
