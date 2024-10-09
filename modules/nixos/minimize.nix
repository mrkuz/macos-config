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
    noLogin = mkOption {
      default = false;
      type = types.bool;
    };
    noNix = mkOption {
      default = false;
      type = types.bool;
    };
  };

  config = mkIf cfg.enable (mkMerge [
    profile
    {
      nix = {
        channel.enable = false;
        enable = !cfg.noNix;
      };
      nixpkgs.flake = {
        setNixPath = false;
        setFlakeRegistry = false;
      };
      services.timesyncd.enable = false;
      system.disableInstallerTools = true;
      systemd = {
        coredump.enable = false;
        oomd.enable = false;
        enableEmergencyMode = false;
      };
      xdg.menus.enable = false;
    }
    (mkIf (cfg.noLogin) {
      services.journald.console = "/dev/console";
      systemd.services = {
        "autovt@".enable = false;
        "getty@".enable = false;
        "serial-getty@".enable = false;
      };
    })
  ]);
}
