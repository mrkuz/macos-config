{ config, lib, pkgs, nixpkgs, self, ... }:
{
  modules = {
    fonts.enable = true;
    hunspell.enable = true;
    nix.enable = true;
    tuptime.enable = true;
  };

  documentation.info.enable = false;

  environment.systemPackages = with pkgs; [ socket_vmnet ];
  environment.launchDaemons.socket_vmnet = {
    source = "${pkgs.socket_vmnet}/Library/LaunchDaemons/io.github.lima-vm.socket_vmnet.plist";
    target = "io.github.lima-vm.socket_vmnet.plist";
    copy = true;
  };

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
