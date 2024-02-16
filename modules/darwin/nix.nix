{ config, lib, pkgs, nixpkgs, self, ... }:
with lib;
let
  cfg = config.modules.nix;
in
{
  imports = [ ../common/nix.nix ];
  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      nil
      niv
      nix-index
    ];

    services.nix-daemon.enable = true;
    
    system = {
      stateVersion = self.vars.darwin.stateVersion;
      configurationRevision = self.vars.rev;
      # Workaround for issue: 'sandbox-exec: pattern serialization length X exceeds maximum (65535)'
      systemBuilderArgs.sandboxProfile = ''
        (allow file-read* file-write* process-exec mach-lookup (subpath "${builtins.storeDir}"))
      '';
    };
  };
}
