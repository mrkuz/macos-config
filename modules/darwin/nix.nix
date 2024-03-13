{ config, lib, pkgs, nixpkgs, vars, ... }:
with lib;
let
  cfg = config.modules.nix;
in
{
  imports = [ ../common/nix.nix ];
  config = mkIf cfg.enable {

    services.nix-daemon.enable = true;
    
    system = {
      stateVersion = vars.darwin.stateVersion;
      configurationRevision = vars.rev;
      # Workaround for issue: 'sandbox-exec: pattern serialization length X exceeds maximum (65535)'
      # See: https://github.com/NixOS/nix/issues/4119
      systemBuilderArgs.sandboxProfile = ''
        (allow file-read* file-write* process-exec mach-lookup (subpath "${builtins.storeDir}"))
      '';
    };
  };
}
