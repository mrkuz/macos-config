{ config, lib, pkgs, systemName, ... }:
{
  modules = {
    alacritty = {
      enable = true;
      shell = "${pkgs.tmux}/bin/tmux";
    };
    tmux = {
      enable = true;
      shell = "${pkgs.fish}/bin/fish";
    };
  };

  home = {
    packages = with pkgs; [
      # CLI utils
      age
      bat
      cloc
      colordiff
      eza
      fd
      file
      htop
      iftop
      inetutils
      jq
      mise
      ncdu
      # pdftk
      pstree
      pwgen
      rclone
      rsync
      ripgrep
      socat
      tree
      watch
      wdiff
      wget
    ];
  };

  programs.fish = {
    enable = true;
    plugins = [
      {
        name = "pure";
        src = pkgs.fishPlugins.pure.src;
      }
    ];
    shellAbbrs = {
      gau = "git add -u";
      gc = "git commit";
      gcm = "git commit -m";
      gd = "git diff";
      gdc = "git diff --cached";
      gs = "git status";
      nb = "nix build --log-format bar-with-logs";
    };
    interactiveShellInit = ''
      set -U fish_greeting
      set -U pure_symbol_prompt ">"
      set -U pure_color_mute "brgreen"
      set -U pure_enable_nixdevshell true
      set -U pure_enable_single_line_prompt true
      set -U fish_color_autosuggestion 586e75
      fish_add_path $HOME/bin
      fish_add_path $HOME/.local/bin/
      ${pkgs.mise}/bin/mise activate fish | source
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
    extraConfig = {
      init = {
        defaultBranch = "main";
      };
      merge = {
        ff = false;
      };
      pull = {
        rebase = true;
      };
    };
    signing = {
      signByDefault = false;
      format = "openpgp";
    };
  };
}
