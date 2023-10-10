{ pkgs, lib, nixpkgs, self, ... }:
{
  environment.systemPackages = with pkgs; [
    niv
    nix-index
    hunspell
    hunspellDicts.de_AT
    hunspellDicts.en_US
  ];

  environment.pathsToLink = [ "/share/hunspell" ];

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

  environment.etc."nix/current".source = self;
  environment.etc."nix/nixpkgs".source = nixpkgs;

  documentation.info.enable = false;

  homebrew = {
    enable = false;
    casks = [
      "betterdisplay"
      "libreoffice"
      "hyperkey"
      "whisky"
    ];
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
