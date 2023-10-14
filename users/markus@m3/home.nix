{ config, pkgs, ... }:
{
  modules = {
    emacs.enable = true;
    kitty = {
      enable = true;
      enableFishIntegration = true;
      shell = "${pkgs.tmux}/bin/tmux";
    };
    tmux = {
      enable = true;
      shell = "${pkgs.fish}/bin/fish";
    };
  };

  home = {
    packages = with pkgs; [
      docker
      # MacOS
      lima-bin
      mas
      rectangle
      utm
      # CLI utils
      age
      bat
      fd
      htop
      iftop
      jq
      ncdu
      pdftk
      pwgen
      rclone
      ripgrep
      socat
      tree
      wget
    ];
    sessionVariables = {
      HOMEBREW_BUNDLE_FILE = "/Users/markus/etc/config.git/var/Brewfile";
    };
  };

  programs.fish = {
    enable = true;
    plugins = [
      {
        name = "sdkman";
        src = pkgs.fishPlugins.sdkman-for-fish.src;
      }
      {
        name = "pure";
        src = pkgs.fishPlugins.pure.src;
      }
    ];
    shellAliases = {
      ec = "emacsclient --socket-name /var/folders/tm/s0rmv44130v_l7p3jynpdkm00000gn/T/emacs501/default -n -c";
    };
    shellAbbrs = {
      a86 = "arch -x86_64";
      gau = "git add -u";
      gdc = "git diff --cached";
      gs = "git status";
    };
    interactiveShellInit = ''
      set -U fish_greeting
    '';
  };

  programs.fzf = {
    enable = true;
    enableFishIntegration = true;
  };

  programs.git = {
    enable = true;
    userName = "mrkuz";
    userEmail = "markus@bitsandbobs.net";
    diff-so-fancy.enable = true;
  };

  services.syncthing.enable = true;
}
