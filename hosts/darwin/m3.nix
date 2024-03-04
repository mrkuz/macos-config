{ config, lib, pkgs, nixpkgs, self, ... }:
{
  modules = {
    fonts.enable = true;
    hunspell.enable = true;
    nix.enable = true;
    socketVmnet.enable = true;
    tuptime.enable = true;
  };

  documentation.info.enable = false;

  nix.linux-builder = {
    enable = true;
    ephemeral = true;
    # config = ({ ... }: {
    #   virtualisation.darwin-builder.diskSize = 30 * 1024;
    # });
  };

  # Disable auto-start, use 'sudo launchctl start org.nixos.linux-builder'
  launchd.daemons.linux-builder.serviceConfig = {
    KeepAlive = lib.mkForce false;
    RunAtLoad = lib.mkForce false;
  };

  nix.settings.trusted-users = [ "root" "markus" ];

  programs = {
    fish.enable = true;
    zsh.enable = true;
  };

  users.users.markus = {
    home = "/Users/markus";
  };

  home-manager.users."markus" = ./. + "/../../users/darwin/markus@m3.nix";
}
