{ config, lib, pkgs, nixpkgs, vars, ... }:
{
  modules = {
    nix.enable = true;
    minimize.enable = false;
    qemuGuest = {
      autoLogin = true;
      dhcp = true;
      user = vars.primaryUser;
      socketVmnet = true;
    };
  };
}
