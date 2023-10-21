{ pkgs, lib, nixpkgs, self, ... }:
{
  modules = {
    fonts.enable = true;
    hunspell.enable = true;
    nix.enable = true;
    tuptime.enable = true;
  };

  documentation.info.enable = false;

  programs = {
    fish.enable = true;
    zsh.enable = true;
  };

  users.users.markus = {
    home = "/Users/markus";
  };

  home-manager.users."markus" = ./. + "/../../users/markus@m3/home.nix";
}
