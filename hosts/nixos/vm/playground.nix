{ config, lib, pkgs, nixpkgs, self, ... }:
{
  modules = {
    nix.enable = true;
    minimize.enable = false;
    qemuGuest.user = self.vars.primaryUser;
  };
}
