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
      colima
      lima-bin
      mas
      # GUI utils
      baobab
      vscode
      # CLI utils
      age
      android-tools
      bat
      fd
      fnm
      htop
      iftop
      inetutils
      jq
      ncdu
      pdftk
      pstree
      pwgen
      rclone
      ripgrep
      socat
      tree
      watch
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
      gc = "git commit";
      gcm = "git commit -m";
      gd = "git diff";
      gdc = "git diff --cached";
      gs = "git status";
    };
    interactiveShellInit = ''
      set -U fish_greeting
      ${pkgs.fnm}/bin/fnm env | source
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
