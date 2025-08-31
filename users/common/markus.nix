{ config, lib, pkgs, systemName, ... }:
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
}
