{ config, pkgs, ... }:
{
  programs.fish = {
    enable = true;
    plugins = [
      {
        name = "sdkman";
        src = pkgs.fishPlugins.sdkman-for-fish;
      }
      # {
      #   name = "pure";
      #   src = pkgs.fishPlugins.pure;
      # }
    ];
    shellAbbrs = {
      gau = "git add -u";
      gdc = "git diff --cached";
      gs = "git status";
    };
    interactiveShellInit = ''
      set -U fish_greeting
    '';
  };

  programs.kitty = {
    enable = true;
    shellIntegration = {
      enableFishIntegration = true;
      mode = "no-cursor";
    };
    theme = "Solarized Dark";
    font = {
      name = "SF Mono";
      size = 14;
    };
    settings = {
      cursor_shape = "block";
      cursor_blink_interval = 0;
      copy_on_select = "clipboard";
      mouse_hide_wait = 0;
      shell = "${pkgs.fish}/bin/fish -il";
      strip_trailing_spaces = "smart";
    };
  };

  home = {
    packages = with pkgs; [
      emacs-unstable
      rectangle
    ];
  };
}
