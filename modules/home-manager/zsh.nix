{ config, lib, pkgs, pkgsStable, ... }:
with lib;
let
  cfg = config.modules.zsh;
in
{
  options.modules.zsh = {
    enable = mkOption {
      default = false;
      type = types.bool;
    };
    extraInit = mkOption {
      type = types.lines;
      default = "";
    };
  };

  config = mkIf cfg.enable {
    home.shell.enableZshIntegration = true;

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
        abbreviations = import ./shell/abbr.nix;
      };
      sessionVariables = {
        "PURE_PROMPT_SYMBOL" = " >";
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

        # Single-line prompt
        prompt_newline='%666v'
        print() {
          [ 0 -eq $# -a "prompt_pure_precmd" = "''${funcstack[-1]}" ] || builtin print "$@";
        }

        prompt pure

        ${cfg.extraInit or ""}
      '';
    };
  };
}
