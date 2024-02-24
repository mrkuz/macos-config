{ config, pkgs, ... }:
{
  home = {
    packages = with pkgs; [ bat ];
  };

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
}
