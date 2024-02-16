{ pkgs, lib, nixpkgs, self, ... }:
{
  imports = [
    ../../profiles/nixos/minimal.nix
  ];

  modules = {
    nix.enable = true;
  };

  virtualisation = {
    graphics = false;
    diskImage = null;
  };

  users = {
    users.root = {
      password = "root";
    };
  };
}
