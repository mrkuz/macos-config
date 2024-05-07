{ config, lib, pkgs, systemName, ... }:
{
  modules = {
    emacs.enable = true;
    kitty = {
      enable = true;
      enableFishIntegration = true;
      shell = "${pkgs.tmux}/bin/tmux";
    };
    tmux = {
      enable = true;
      shell = "${pkgs.fish}/bin/fish";
    };
  };

  home = {
    packages = with pkgs; [
      docker
      # MacOS
      mas
      # Virtualisation
      macos.qemu
      # GUI utils
      baobab
      vscode
      # CLI utils
      age
      bat
      cloc
      eza
      fd
      htop
      iftop
      inetutils
      jq
      # ncdu
      pdftk
      pstree
      pwgen
      rclone
      rsync
      ripgrep
      socat
      tree
      watch
      wget
      # Android
      android-tools
      # Node.js
      fnm
      # Cloud
      (google-cloud-sdk.withExtraComponents [ google-cloud-sdk.components.gke-gcloud-auth-plugin ])
      kubectl
      kubernetes-helm
      terraform
      # VMs
      (lib.buildQemuVm {
        name = "docker";
        targetSystem = "aarch64-linux";
        configuration = {
          imports = [
            ../../hosts/nixos/vm/docker.nix
          ];
          virtualisation.diskImage = "/Users/markus/var/docker.qcow2";
        };
      })
    ];
    sessionVariables = {
      HOMEBREW_BUNDLE_FILE = "/Users/markus/etc/config.git/var/${systemName}/Brewfile";
    };
  };

  programs.fish = {
    enable = true;
    plugins = [
      {
        name = "sdkman";
        src = pkgs.fishPlugins.sdkman-for-fish.src;
      }
      {
        name = "pure";
        src = pkgs.fishPlugins.pure.src;
      }
    ];
    shellAliases = {
      ec = "emacsclient --socket-name /var/folders/tm/s0rmv44130v_l7p3jynpdkm00000gn/T/emacs501/default -n -c";
    };
    shellAbbrs = {
      a86 = "arch -x86_64";
      gau = "git add -u";
      gc = "git commit";
      gcm = "git commit -m";
      gd = "git diff";
      gdc = "git diff --cached";
      gs = "git status";
      nb = "nix build --log-format bar-with-logs";
    };
    interactiveShellInit = ''
      set -U fish_greeting
      fish_add_path $HOME/bin
      ${pkgs.fnm}/bin/fnm env | source
    '';
  };

  programs.fzf = {
    enable = true;
    enableFishIntegration = true;
  };

  programs.git = {
    enable = true;
    userName = "mrkuz";
    userEmail = "markus@bitsandbobs.net";
    diff-so-fancy.enable = true;
    extraConfig = {
      init = {
        defaultBranch = "main";
      };
      merge = {
        ff = false;
      };
      pull = {
        rebase = true;
      };
    };
  };
}
