{ config, lib, pkgs, nixpkgs, options, ... }:
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
    graphics = mkOption {
      default = false;
      type = types.bool;
    };
    opengl = mkOption {
      default = false;
      type = types.bool;
    };
    user =  mkOption {
      default = null;
      type = types.nullOr types.str;
    };
    autoLogin = mkOption {
      default = false;
      type = types.bool;
    };
    dhcp = mkOption {
      default = false;
      type = types.bool;
    };
    sshd = mkOption {
      default = false;
      type = types.bool;
    };
    vmnet = mkOption {
      default = false;
      type = types.bool;
    };
    socketVmnet = mkOption {
      default = false;
      type = types.bool;
    };
  };

  config = mkIf cfg.enable (mkMerge [
    {
      security.sudo = {
        execWheelOnly = true;
        wheelNeedsPassword = false;
      };

      users = {
        allowNoPasswordLogin = true;
        mutableUsers = false;
        users.root = {
          hashedPassword = "*";
        };
      };
    }
    (mkIf (cfg.dhcp) {
      networking = {
        dhcpcd.enable = mkDefault true;
        useDHCP = mkDefault true;
      };
    })
    (mkIf (!cfg.dhcp) {
      networking = (mkMerge [
        {
          dhcpcd.enable = mkDefault false;
          useDHCP = mkDefault false;
        }
        (mkIf (cfg.socketVmnet) {
          defaultGateway = "192.168.105.1";
          nameservers = [ "192.168.105.1" ];
        })
        (mkIf (!cfg.socketVmnet && cfg.vmnet) {
          defaultGateway = "192.168.64.1";
          nameservers = [ "192.168.64.1" ];
        })
        (mkIf (!cfg.socketVmnet && !cfg.vmnet) {
          defaultGateway = "10.0.2.2";
          nameservers = [ "10.0.2.3" ];
          interfaces.eth0.ipv4.addresses = [
            {
              address = "10.0.2.15";
              prefixLength = 24;
            }
          ];
        })
      ]);
    })
    (mkIf (cfg.user != null) {
      services.getty.autologinUser = mkIf cfg.autoLogin cfg.user;
      services.displayManager.autoLogin.user = mkIf cfg.autoLogin cfg.user;

      services.openssh.settings = {
        AllowUsers = [ cfg.user ];
        PermitRootLogin = "no";
      };

      users.users."${cfg.user}" = {
        isNormalUser = true;
        hashedPassword = mkIf (config.users.users."${cfg.user}".password == null) "*";
        extraGroups = [ "wheel" ];
      };
    })
    (mkIf (cfg.sshd != null) {
      environment.etc = {
        "ssh/ssh_host_rsa_key" = {
          mode = "0600";
          source = ./qemu-guest/ssh_host_rsa_key;
        };
        "ssh/ssh_host_rsa_key.pub" = {
          mode = "0644";
          source = ./qemu-guest/ssh_host_rsa_key.pub;
        };
        "ssh/ssh_host_ed25519_key" = {
          mode = "0600";
          source = ./qemu-guest/ssh_host_ed25519_key;
        };
        "ssh/ssh_host_ed25519_key.pub" = {
          mode = "0644";
          source = ./qemu-guest/ssh_host_ed25519_key.pub;
        };
      };

      services.openssh = {
        enable = true;
        openFirewall = true;
        settings = {
          StrictModes = false;
          PasswordAuthentication = false;
        };
      };
    })
    (mkIf (cfg.graphics) {
      hardware.graphics.enable = mkDefault true;
    })
    (mkIf (!cfg.graphics) {
      environment = {
        systemPackages = with pkgs; [ resize ];
        loginShellInit = ''
          "${resize}/bin/resize";
          export TERM=screen-256color
        '';
      };

      services.getty.helpLine = ''
        Type 'Ctrl-a c' to switch to the QEMU console
      '';

      # Disable virtual console
      systemd.services."autovt@".enable = false;
      systemd.services."getty@".enable = false;
    })
  ]);
}
