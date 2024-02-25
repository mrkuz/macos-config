{ config, lib, pkgs, nixpkgs, self, options, ... }:
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
    noLogin = mkOption {
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

      virtualisation = vmAttrs options {
        resolution = { x = 1920; y = 1200; };
        diskImage = null;
        diskSize = 10 * 1024;
        cores = 2;
        memorySize = 4096;
      };
    }
    (mkIf (cfg.dhcp) {
      networking = {
        dhcpcd.enable = true;
        useDHCP = true;
      };
    })
    (mkIf (!cfg.dhcp) {
      networking = (mkMerge [
        {
          dhcpcd.enable = false;
          useDHCP = false;
        }
        (mkIf (cfg.vmnet) {
          defaultGateway = "192.168.64.1";
          nameservers = [ "192.168.64.1" ];
        })
        (mkIf (!cfg.vmnet) {
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
    (mkIf (cfg.vmnet) {
      virtualisation = vmAttrs options {
        qemu.networkingOptions = [
          "-device virtio-net-device,netdev=net.0"
          "-netdev vmnet-shared,id=net.0,\${QEMU_NET_OPTS:+,$QEMU_NET_OPTS}"
        ];
      };
    })
    (mkIf (cfg.noLogin) {
      services.getty = {
        loginProgram = "${pkgs.coreutils-full}/bin/sleep";
        loginOptions = "infinity";
        extraArgs = [ "--skip-login" ];
      };
    })
    (mkIf (cfg.user != null) {
      services.getty.autologinUser = mkIf cfg.autoLogin cfg.user;
      services.xserver.displayManager.autoLogin.user = mkIf cfg.autoLogin cfg.user;

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
          X11Forwarding = true;
        };
      };
    })
    (mkIf (cfg.graphics) {
      virtualisation = vmAttrs options {
        graphics = true;
        qemu = {
          options = [ "-display default,show-cursor=on" ];
        };
      };
    })
    (mkIf (!cfg.graphics) {
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

      virtualisation = vmAttrs options {
        graphics = false;
        qemu = {
          options = [ "-vga none" ];
          consoles = [ "ttyAMA0,115200n8" ];
        };
      };
    })
  ]);
}
