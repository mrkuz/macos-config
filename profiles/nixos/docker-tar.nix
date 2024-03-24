{ config, lib, pkgs, nixpkgs, modulesPath, ... }:
{
  imports = [
    "${modulesPath}/virtualisation/docker-image.nix"
  ];

  networking.nameservers = lib.mkDefault [ "8.8.8.8" ];
}
