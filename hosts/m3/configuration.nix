{ pkgs, lib, nixpkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    # git
    # gcc
  ];

  programs.zsh.enable = true;

  services.nix-daemon.enable = true;

  nix = {
    package = pkgs.nixFlakes;
    settings.experimental-features = "nix-command flakes";
  };

  # Use local nixpkgs
  nix.registry.nixpkgs = {
    from = {
      id = "nixpkgs";
      type = "indirect";
    };
    to = lib.mkForce {
      path = "${nixpkgs}";
      type = "path";
    };
  };

  homebrew = {
    enable = true;
    # brews = [
    #   { name = "sdkman-cli"; }
    # ];
    # taps = [
    #   { name = "sdkman/tap"; }
    # ];
  };

  users.users.markus = {
    home = "/Users/markus";
  };

  home-manager.users."markus" = ./. + "/../../users/markus@m3/home.nix";
}
