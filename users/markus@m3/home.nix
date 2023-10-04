{ config, pkgs, ... }:
{
  programs.fish = {
    enable = true;
    plugins = [
      {
        name = "sdkman";
        src = pkgs.fetchFromGitHub {
          owner = "reitzig";
          repo = "sdkman-for-fish";
          rev = "v1";
          hash = "sha256-cgDTunWFxFm48GmNv21o47xrXyo+sS6a3CzwHlv0Ezo=";
        };
      }
    ];
  };

  home = {
    packages = with pkgs; [
      emacs-unstable
      rectangle
    ];
  };
}
