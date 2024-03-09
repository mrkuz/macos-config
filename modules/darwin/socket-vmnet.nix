{ config, lib, pkgs, nixpkgs, ... }:
with lib;
let
  cfg = config.modules.socketVmnet;
in
{
  options.modules.socketVmnet = {
    enable = mkOption {
      default = false;
      type = types.bool;
    };
    gateway =  mkOption {
      default = "192.168.105.1";
      type = types.str;
    };
    dhcpEnd =  mkOption {
      default = "192.168.105.100";
      type = types.str;
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      macos.socket_vmnet
    ];

    launchd.daemons.socket-vmnet = {
      serviceConfig = {
        ProgramArguments = [
          "/bin/sh" "-c"
          "/bin/wait4path ${pkgs.macos.socket_vmnet} &amp;&amp; ${pkgs.macos.socket_vmnet}/bin/socket_vmnet --vmnet-gateway=${cfg.gateway} --vmnet-dhcp-end=${cfg.dhcpEnd} /var/run/socket_vmnet"
        ];
        RunAtLoad = true;
        StandardOutPath = "/var/log/socket-vmnet/stdout";
        StandardErrorPath = "/var/log/socket-vmnet/stderr";
        UserName = "root";
      };
    };
  };
}
