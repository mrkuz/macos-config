{ config, pkgs, ... }:
{
  home = {
    packages = with pkgs; [
      emacs-unstable
      rectangle
    ];

    stateVersion = "23.05";
  };
}
