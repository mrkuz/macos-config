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

  home.file.".config/skhd/skhdrc".text = ''
    # Disable close window
    cmd - w : true
    # Hyper keymap
    :: hyper_mode
    f19 ; hyper_mode
    hyper_mode < e : skhd -k "q"; emacsclient --socket-name /var/folders/39/fty64sbs0h14_3bh2rqq7q9m0000gn/T/emacs501/default -n -c
    hyper_mode < t : skhd -k "q"; alacritty
    hyper_mode < q ; default
    hyper_mode < f19 ; default
  '';

  programs.fish = {
    enable = true;
    plugins = [
      # {
      #   name = "pure";
      #   src = pkgs.fishPlugins.pure.src;
      # }
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
      set -U fish_color_autosuggestion 586e75
      fish_add_path $HOME/bin
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
