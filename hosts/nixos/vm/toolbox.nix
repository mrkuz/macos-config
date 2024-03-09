{ config, lib, pkgs, nixpkgs, vars, ... }:
{
  modules = {
    nix.enable = true;
    minimize.enable = false;
    qemuGuest = {
      autoLogin = true;
      dhcp = true;
      socketVmnet = true;
      user = vars.primaryUser;
    };
  };

  programs.fish.enable = true;
  users.users."${vars.primaryUser}".shell = pkgs.fish;

  home-manager.users."${vars.primaryUser}" = {
    home.packages = with pkgs; [
      # General utils
      bat
      htop
      # Cloud utils
      awscli2
      kubectl
      kubernetes-helm
    ];

    programs.fish = {
      enable = true;
      interactiveShellInit = ''
        set -U fish_greeting
      '';
    };

    programs.fzf = {
      enable = true;
      enableFishIntegration = true;
    };
  };
}
