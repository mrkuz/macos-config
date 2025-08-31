{ config, lib, pkgs, systemName, ... }:
{
  imports = [ ../common/markus.nix  ];

  modules = {
    emacs.enable = true;
    tmux = {
      enable = true;
      copyCommand = "pbcopy";
    };
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
      # Python
      # (python3.withPackages (p: [
      #   p.flake8
      #] ))
      uv
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
      OLLAMA_API_BASE="http://127.0.0.1:11434";
    };
  };

  home.file.".config/skhd/skhdrc".text = ''
    # Disable close window
    cmd - w : true
    # Hyper keymap
    :: hyper_mode
    f19 ; hyper_mode
    hyper_mode < a : skhd -k "q"; open -n /System/Applications/Launchpad.app
    hyper_mode < e : skhd -k "q"; emacsclient --socket-name /var/folders/39/fty64sbs0h14_3bh2rqq7q9m0000gn/T/emacs501/default -n -c
    hyper_mode < j : skhd -k "q"; emacsclient --socket-name /var/folders/39/fty64sbs0h14_3bh2rqq7q9m0000gn/T/emacs501/default -n -c -F '((name . "org-protocol-capture"))' 'org-protocol://capture?template=j'
    hyper_mode < t : skhd -k "q"; osascript -e 'tell application "Terminal" to do script ""'
    hyper_mode < q ; default
    hyper_mode < f19 ; default
  '';

  programs.ssh = {
    enable = true;
    extraConfig = "UseKeychain = yes";
    matchBlocks."*" = {
      addKeysToAgent = "yes";
    };
  };

  programs.zsh = {
    shellAliases = {
      ec = "emacsclient --socket-name /var/folders/39/fty64sbs0h14_3bh2rqq7q9m0000gn/T/emacs501/default -n -c";
    };
  };

  services.ollama = {
    enable = true;
    environmentVariables = {
       OLLAMA_CONTEXT_LENGTH = "8192";
    };
  };

  targets.darwin.linkApps.enable = false;
}
