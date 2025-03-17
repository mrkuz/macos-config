{ config, lib, pkgs, nixpkgs, ... }:
{
  nix.linux-builder = {
    enable = true;
    ephemeral = true;
  };
}
