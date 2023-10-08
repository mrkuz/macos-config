{ pkgs, lib, nixpkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    # git
    # gcc
  ];

  programs = {
    fish.enable = true;
    zsh.enable = true;
  };

  services.nix-daemon.enable = true;

  nix = {
    settings = {
      experimental-features = "nix-command flakes";
      narinfo-cache-positive-ttl = 86400;
      keep-outputs = true;
      keep-derivations = true;
      auto-optimise-store = true;
      sandbox = true;
    };
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

  environment.extraInit = ''
    export NIX_PATH="nixpkgs=${nixpkgs}"
  '';

  homebrew = {
    enable = false;
    # casks = [ "libreoffice" "whisky" ];
    brews = [ ];
    taps = [ ];
  };

  fonts = {
    fontDir.enable = true;
    fonts = with pkgs; [
      dejavu_fonts
      source-code-pro
      ubuntu_font_family
    ];
  };

  users.users.markus = {
    home = "/Users/markus";
  };

  home-manager.users."markus" = ./. + "/../../users/markus@m3/home.nix";
}
