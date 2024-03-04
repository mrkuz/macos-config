{ config, lib, pkgs, nixpkgs, self, ... }:
{
  modules = {
    nix.enable = true;
    minimize.enable = false;
    qemuGuest = {
      autoLogin = true;
      dhcp = true;
      user = self.vars.primaryUser;
      socketVmnet = true;
    };
  };
}
