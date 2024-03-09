{ config, lib, pkgs, nixpkgs, modulesPath, ... }:
with lib;
let
  cfg = config.modules.minimize;
  profile = import "${modulesPath}/profiles/minimal.nix" { inherit config lib; };
in {
  options.modules.minimize = {
    enable = mkOption {
      default = false;
      type = types.bool;
    };
  };

  config = mkIf cfg.enable (profile // {
    environment.noXlibs = false;
    system.disableInstallerTools = true;
    systemd.oomd.enable = false;
    xdg.menus.enable = false;
  });
}
