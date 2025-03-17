{ config, lib, pkgs, systemName, ... }:
{
  imports = [ ../common/markus.nix  ];

  modules = {
    emacs.enable = true;
  };

  home = {
    packages = with pkgs; [
      docker
      # MacOS
      mas
      # Virtualisation
      # lima
      macos.qemu
      # GUI utils
      vscode
      # Cloud
      # kubectl
      # kubernetes-helm
      # terraform
      # VMs
      (lib.buildQemuVm {
        name = "docker";
        targetSystem = "aarch64-linux";
        configuration = {
          imports = [
            ../../vms/nixos/docker.nix
          ];
          virtualisation.diskImage = "/Users/markus/var/docker.qcow2";
        };
      })
    ];
    sessionVariables = {
      HOMEBREW_BUNDLE_FILE = "/Users/markus/etc/config.git/var/${systemName}/Brewfile";
    };
  };

  programs.alacritty = {
    settings = {
      font = {
        normal = {
          family = "Ubuntu Mono";
          style = "Regular";
        };
        offset = { x = 0; y = 2; };
        size = 18;
      };
    };
  };

  programs.fish = {
    shellAliases = {
      ec = "emacsclient --socket-name /var/folders/39/fty64sbs0h14_3bh2rqq7q9m0000gn/T/emacs501/default -n -c";
    };
    shellAbbrs = {
      a86 = "arch -x86_64";
    };
  };
}
