{ config, lib, pkgs, systemName, ... }:
let
  shellAbbrs = {
    gau = "git add -u";
    gc = "git commit";
    gcm = "git commit -m";
    gcmm = "git checkout --";
    gd = "git diff";
    gdc = "git diff --cached";
    gs = "git status";
    nb = "nix build --log-format bar-with-logs";
  };
in {
  home = {
    packages = with pkgs; [
      # CLI utils
      age
      bat
      cloc
      colordiff
      entr
      eza
      fd
      file
      httpie
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
      tldr
      tree
      watch
      wdiff
      wget
    ];
  };

  home.shell = {
    # enableFishIntegration = true;
    enableZshIntegration = true;
  };

  programs.fish = {
    enable = false;
    plugins = [
      {
        name = "pure";
        src = pkgs.fishPlugins.pure.src;
      }
    ];
    shellAbbrs = shellAbbrs;
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

  programs.fzf.enable = true;

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

  programs.zsh = {
    enable = true;
    autocd = true;
    autosuggestion.enable = true;
    defaultKeymap = "emacs";
    enableCompletion = true;
    history = {
      save = 10000;
      size = 10000;
      share = true;
      ignoreDups = true;
      ignoreAllDups = true;
      saveNoDups = true;
      findNoDups = true;
      expireDuplicatesFirst = true;
      ignoreSpace = true;
    };
    syntaxHighlighting.enable = true;
    zsh-abbr = {
      enable = true;
      abbreviations = shellAbbrs;
    };
    sessionVariables = {
      "CLICOLOR" = "1";
      "PURE_PROMPT_SYMBOL" = ">";
    };
    setOptions = [
      "INC_APPEND_HISTORY"
      "HIST_REDUCE_BLANKS"
    ];
    plugins = [
      {
        name = "pure";
        src = pkgs.pure-prompt;
        completions = [ "share/zsh/site-functions" ];
      }
    ];
    initContent = ''
      bindkey "^[[3~" delete-char

      autoload -U promptinit; promptinit
      zstyle :prompt:pure:git:stash show yes
      prompt pure

      eval "$(${pkgs.mise}/bin/mise activate zsh)"
    '';
  };
}
