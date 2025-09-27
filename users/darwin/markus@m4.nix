{ config, lib, pkgs, systemName, ... }:
{
  imports = [ ../common/markus.nix  ];

  modules = {
    emacs.enable = true;
    tmux = {
      enable = true;
      copyCommand = "pbcopy";
      shell = "${pkgs.fish}/bin/fish";
    };
    fish = {
      enable = true;
      extraInit = ''
        ${pkgs.mise}/bin/mise activate fish | source
      '';
    };
    zsh = {
      enable = false;
      extraInit = ''
        eval "$(${pkgs.mise}/bin/mise activate zsh)"
      '';
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
      # CLI utils
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
      CLICOLOR = "1";
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
    hyper_mode < t : skhd -k "q"; osascript -e 'tell application "Terminal" to do script "" activate'
    hyper_mode < q ; default
    hyper_mode < f19 ; default
  '';

  home.shellAliases = {
    ec = "emacsclient --socket-name /var/folders/39/fty64sbs0h14_3bh2rqq7q9m0000gn/T/emacs501/default -n -c";
  };

  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    extraConfig = "UseKeychain = yes";
    matchBlocks."*" = {
      addKeysToAgent = "yes";
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
