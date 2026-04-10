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
      cloc
      colordiff
      curl
      entr
      file
      httpie
      iftop
      inetutils
      ncdu
      # pdftk
      pstree
      pwgen
      rsync
      socat
      tree
      watch
      wdiff
      wget
    ];
  };

  programs = {
    bat.enable = true;
    fd.enable = true;
    fzf.enable = true;
    htop.enable = true;
    jq.enable = true;
    ripgrep.enable = true;
    rclone.enable = true;
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
}
