{ config, pkgs, ... }:
{
  home = {
    packages = with pkgs; [
      emacs-unstable
    ];

    stateVersion = "23.05";
  };
}
