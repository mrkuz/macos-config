{ config, lib, pkgs, nixpkgs, self, modulesPath, options, ... }:
with lib;
let
  cfg = config.modules.qemuGuest;
  # See: https://unix.stackexchange.com/questions/16578/resizable-serial-console-window
  resize = pkgs.writeScriptBin "resize" ''
    if [ -e /dev/tty ]; then
      old=$(stty -g)
      stty raw -echo min 0 time 5
      printf '\033[18t' > /dev/tty
      IFS=';t' read -r _ rows cols _ < /dev/tty
      stty "$old"
      stty cols "$cols" rows "$rows"
    fi
  '';
in
{
  options.modules.qemuGuest = {
    enable = mkOption {
      default = false;
      type = types.bool;
    };
  };

  config = mkIf cfg.enable (mkMerge [
    {
    }
    (mkIf (config.virtualisation.graphics) {
      virtualisation.qemu = {
        options = [ "-display default,show-cursor=on" ];
      };
    })
    (mkIf (!config.virtualisation.graphics) {
      environment = {
        systemPackages = with pkgs; [resize ];
        loginShellInit = ''
          "${resize}/bin/resize";
          export TERM=screen-256color
        '';
      };

      services.getty.helpLine = ''
        Type 'Ctrl-a c' to switch to the QEMU console
      '';

      # Disable virtual console
      systemd.units."autovt@tty1.service".enable = false;

      virtualisation.qemu = {
        options = [ "-vga none" ];
        consoles = [ "ttyAMA0,115200n8" ];
      };
    })
  ]);
}
