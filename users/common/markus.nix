{
  config,
  lib,
  pkgs,
  systemName,
  ...
}:
{
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

  programs.diff-so-fancy = {
    enable = true;
    enableGitIntegration = true;
  };

  programs.git = {
    enable = true;
    settings = {
      user = {
        name = "mrkuz";
        email = "markus@bitsandbobs.net";
      };
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

  programs.mise.enable = true;
  programs.skim.enable = true;
}
