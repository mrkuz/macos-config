{ config, lib, pkgs, nixpkgs, modulesPath, ... }:
{
  imports = [
    "${modulesPath}/profiles/qemu-guest.nix"
  ];

  boot = {
    growPartition = true;
    kernelParams = ["console=ttyS0"];
    loader = {
      grub = {
        enable = false;
        device = "nodev";
        efiSupport = true;
        efiInstallAsRemovable = true;
      };
      systemd-boot.enable = true;
      timeout = 0;
    };
  };

  fileSystems."/" = {
    device = "/dev/disk/by-label/nixos";
    autoResize = true;
    fsType = "ext4";
  };
}
