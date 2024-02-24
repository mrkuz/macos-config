{ config, lib, pkgs, nixpkgs, self, modulesPath, ... }:
{
  imports = [
    "${modulesPath}/virtualisation/qemu-vm.nix"
  ];
}
