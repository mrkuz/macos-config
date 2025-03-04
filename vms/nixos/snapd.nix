{ config, lib, pkgs, nixpkgs, vars, ... }:
{
  modules = {
    nix.enable = false;
    minimize.enable = false;
    qemuGuest = {
      autoLogin = true;
      socketVmnet = true;
      sshd = true;
      user = vars.primaryUser;
    };
  };

  networking.firewall.enable = false;
  networking.interfaces.eth0.ipv4.addresses = [
    {
      address = "192.168.105.103";
      prefixLength = 24;
    }
  ];

  nix.enable = false;

  services.snap = {
    enable = true;
    snapBinInPath = true;
  };
}
