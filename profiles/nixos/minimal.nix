{ config, lib, pkgs, nixpkgs, self, modulesPath, ... }:
{
  imports = [
    "${modulesPath}/profiles/minimal.nix"
  ];

  environment.noXlibs = false;
  systemd.oomd.enable = false;
  xdg.menus.enable = false;
}
