{ config, lib, pkgs, nixpkgs, self, ... }:
{
  modules = {
    nix.enable = true;
    minimize.enable = false;
    qemuGuest = {
      autoLogin = true;
      dhcp = true;
      socketVmnet = true;
      user = self.vars.primaryUser;
    };
  };

  programs.fish.enable = true;
  users.users."${self.vars.primaryUser}".shell = pkgs.fish;

  home-manager.users."${self.vars.primaryUser}" = {
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
