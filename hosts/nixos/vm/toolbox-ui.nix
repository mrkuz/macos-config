{ config, lib, pkgs, nixpkgs, self, options, ... }:
{
  modules = {
    nix.enable = true;
    minimize.enable = false;
    qemuGuest = {
      autoLogin = true;
      dhcp = true;
      graphics = true;
      socketVmnet = true;
      user = self.vars.primaryUser;
      opengl = true;
    };
  };

  documentation = {
    doc.enable = false;
    info.enable = false;
    nixos.enable = false;
  };

  environment.systemPackages = with pkgs; [
    pantheon.elementary-terminal
    # Base utils
    file
    ripgrep
    # Development
    firefox-devedition
    postman
  ];

  programs.fish.enable = true;
  services.pantheon.apps.enable = false;

  services.xserver = {
    enable = true;
    excludePackages = [ pkgs.xterm ];
    desktopManager.pantheon.enable = true;
  };

  users.users."${self.vars.primaryUser}" = {
    password = self.vars.primaryUser;
    shell = pkgs.fish;
  };

  home-manager.users."${self.vars.primaryUser}" = {
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
