{ config, lib, pkgs, nixpkgs, ...}:
{
  modules = {
    nix.enable = true;
    minimize.enable = false;
    qemuGuest = {
      autoLogin = true;
      dhcp = true;
      user = "user";
      socketVmnet = true;
    };
  };
}
