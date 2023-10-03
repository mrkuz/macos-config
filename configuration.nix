{ pkgs, self, ... }:
{
  environment.systemPackages = with pkgs; [
    gcc
    git
  ];

  programs.zsh.enable = true;

  services.nix-daemon.enable = true;
  nix = {
    package = pkgs.nixFlakes;
    settings.experimental-features = "nix-command flakes";
  };
  nixpkgs.hostPlatform = "aarch64-darwin";

  system = {
    configurationRevision = self.rev or self.dirtyRev or null;
    stateVersion = 4;
  };

  users.users.markus = {
    home = "/Users/markus";
  };

  home-manager.users."markus" = import ./home.nix;
}
