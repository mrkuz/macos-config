{ config, lib, pkgs, nixpkgs, ... }:
with lib;
let
  cfg = config.modules.tuptime;

  tuptimed = pkgs.writeShellScript "tuptimed" ''
    function shutdown()
    {
      ${pkgs.tuptime}/bin/tuptime -q -g
      exit 0
    }

    function startup()
    {
      ${pkgs.tuptime}/bin/tuptime -q
      tail -f /dev/null &
      wait $!
    }

    trap shutdown SIGTERM

    startup;
    '';
in
{
  options.modules.tuptime = {
    enable = mkOption {
      default = false;
      type = types.bool;
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      tuptime
    ];

    launchd.daemons.tuptime = {
      serviceConfig = {
        ProgramArguments = [
          "/bin/sh" "-c"
          "/bin/wait4path ${pkgs.tuptime} &amp;&amp; ${tuptimed}"
        ];
        RunAtLoad = true;
        StandardOutPath = "/var/log/tuptime/stdout";
        StandardErrorPath = "/var/log/tuptime/stderr";
      };
    };
  };
}
