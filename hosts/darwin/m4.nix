{ config, lib, pkgs, nixpkgs, ... }:
{
  modules = {
    fonts.enable = true;
    hunspell.enable = true;
    nix.enable = true;
    socketVmnet.enable = true;
  };

  documentation.info.enable = false;

  networking.hostName = "m4";

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

  # Use Touch ID for sudo
  security.pam.services.sudo_local = {
    enable = true;
    touchIdAuth = true;
    reattach = true;
  };

  # Remap Caps Lock to F19 (fake hyper key)
  system.keyboard = {
    enableKeyMapping = true;
    userKeyMapping = [
      {
        HIDKeyboardModifierMappingSrc = 30064771129;
        HIDKeyboardModifierMappingDst = 30064771182;
      }
    ];
  };

  system.defaults.CustomUserPreferences = {
    "com.apple.symbolichotkeys" = {
      AppleSymbolicHotKeys = {
        # Disable input source switching with 'Control + Space'
        "60" = {
           enabled = false;
        };
      };
    };
  };

  services.skhd.enable = true;
  # Enable firewall
  system.defaults.alf.globalstate = 1;

  system.primaryUser = "markus";
  users.users.markus = {
    home = "/Users/markus";
  };

  home-manager.users."markus" = ./. + "/../../users/darwin/markus@m4.nix";
}
