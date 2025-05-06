{ config, lib, pkgs, nixpkgs, modulesPath, ... }:
with lib;
let
  cfg = config.modules.qemuGuest;
  hostPkgs = config.virtualisation.host.pkgs;
in {
  imports = [
    "${modulesPath}/virtualisation/qemu-vm.nix"
  ];

  system.build.startVm = hostPkgs.runCommand "start-vm" {
    preferLocalBuild = true;
    meta.mainProgram = "start-${config.system.name}-vm";
  }
    ''
      mkdir -p $out/bin
      cp "${config.system.build.vm}/bin/run-${config.system.name}-vm" $out/bin/start-${config.system.name}-vm
      ${if (cfg.graphics && cfg.opengl) then ''
        substituteInPlace $out/bin/start-${config.system.name}-vm --replace "-display default" "-display default,gl=es"
        substituteInPlace $out/bin/start-${config.system.name}-vm --replace "-device virtio-gpu-pci" "-device virtio-gpu-gl-pci"
      '' else ""}
      ${if (cfg.socketVmnet) then ''
        substituteInPlace $out/bin/start-${config.system.name}-vm --replace "exec " "exec ${hostPkgs.macos.socket_vmnet}/bin/socket_vmnet_client /var/run/socket_vmnet "
      '' else ""}
      ${if (cfg.vmnet) then ''
        substituteInPlace $out/bin/start-${config.system.name}-vm --replace "exec " "exec sudo "
      '' else ""}
    '';

  virtualisation = (mkMerge [
    {
      qemu.package = mkIf hostPkgs.stdenv.isDarwin hostPkgs.macos.qemu;
      resolution = mkDefault { x = 1280; y = 720; };
      diskImage = mkDefault null;
      diskSize = mkDefault (10 * 1024);
      cores = mkDefault 2;
      memorySize = mkDefault 4096;
    }
    (mkIf (cfg.socketVmnet) {
      qemu.networkingOptions = [
        "-device virtio-net-device,netdev=net.0"
        "-netdev socket,id=net.0,fd=3,\${QEMU_NET_OPTS:+,$QEMU_NET_OPTS}"
      ];
    })
    (mkIf (!cfg.socketVmnet && cfg.vmnet) {
      qemu.networkingOptions = [
        "-device virtio-net-device,netdev=net.0"
        "-netdev vmnet-shared,id=net.0,\${QEMU_NET_OPTS:+,$QEMU_NET_OPTS}"
      ];
    })
    (mkIf (cfg.graphics) {
      graphics = true;
      qemu = {
        options = [ "-display default" ];
      };
    })
    (mkIf (!cfg.graphics) {
      graphics = false;
      qemu = {
        options = [ "-vga none" ];
        consoles = [ "ttyAMA0,115200n8" ];
      };
    })
  ]);
}
