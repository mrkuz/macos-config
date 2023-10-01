{ pkgs, self, ... }:
{
  environment.systemPackages = with pkgs; [
    git
  ];

  services.nix-daemon.enable = true;
  nix = {
    package = pkgs.nixFlakes;
    settings.experimental-features = "nix-command flakes";
  };
  nixpkgs.hostPlatform = "aarch64-darwin";

  programs.zsh.enable = true;

  system.configurationRevision = self.rev or self.dirtyRev or null;
  system.stateVersion = 4;
}
