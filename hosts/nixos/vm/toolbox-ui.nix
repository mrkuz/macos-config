{ config, lib, pkgs, nixpkgs, vars, options, ... }:
{
  modules = {
    nix.enable = true;
    minimize.enable = false;
    qemuGuest = {
      # autoLogin = true;
      dhcp = true;
      graphics = true;
      opengl = true;
      socketVmnet = true;
      user = vars.primaryUser;
    };
  };

  documentation = {
    doc.enable = false;
    info.enable = false;
    nixos.enable = false;
  };

  environment.gnome.excludePackages = with pkgs; [
    gnome-tour
  ];

  environment.systemPackages = with pkgs; [
    # Base utils
    file
    htop
    ripgrep
    # Development
    firefox-devedition
    postman
  ];

  programs.fish.enable = true;
  programs.gnome-terminal.enable = true;
  services.gnome.core-utilities.enable = false;
  services.gnome.evolution-data-server.enable = lib.mkForce false;

  services.xserver = {
    enable = true;
    excludePackages = [ pkgs.xterm ];
    desktopManager.gnome.enable = true;
    displayManager.gdm.enable = true;
  };

  users.users."${vars.primaryUser}" = {
    password = vars.primaryUser;
    shell = pkgs.fish;
  };

  home-manager.users."${vars.primaryUser}" = {
    modules = {
      tmux = {
        enable = true;
        shell = "${pkgs.fish}/bin/fish";
      };
    };

    programs.fish = {
      enable = true;
      interactiveShellInit = ''
        set -U fish_greeting
        set -gx TERM screen-256color
      '';
    };

    programs.fzf = {
      enable = true;
      enableFishIntegration = true;
    };
  };
}
