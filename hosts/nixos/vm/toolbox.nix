{ config, lib, pkgs, nixpkgs, self, ... }:
{
  modules = {
    nix.enable = true;
    minimize.enable = false;
    qemuGuest = {
      user = self.vars.primaryUser;
      autoLogin = true;
    };
  };

  programs.fish.enable = true;
  home-manager.users."${self.vars.primaryUser}" = {
    home.packages = with pkgs; [
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
  users.users."${self.vars.primaryUser}".shell = pkgs.fish;
}
