{
  config,
  lib,
  pkgs,
  systemName,
  ...
}:
let
  docker-compat = pkgs.writeScriptBin "docker" ''
    exec ${pkgs.podman}/bin/podman "$@"
  '';
in
{
  imports = [ ../common/markus.nix ];

  modules = {
    emacs.enable = true;
    tmux = {
      enable = true;
      copyCommand = "pbcopy";
      shell = "${pkgs.fish}/bin/fish";
    };
    alacritty = {
      enable = true;
      shell = "${pkgs.tmux}/bin/tmux";
    };
    fish = {
      enable = true;
    };
  };

  home = {
    packages = with pkgs; [
      # MacOS
      mas
      # AI
      opencode
      # ramalama
      # Virtualization & containers
      docker
      # docker-compat
      docker-compose
      krunkit
      macos.qemu
      # Develpment tools
      devcontainer
      uv
      vscode
    ];
    sessionVariables = {
      CLICOLOR = "1";
      HOMEBREW_BUNDLE_FILE = "/Users/markus/etc/config.git/var/${systemName}/Brewfile";
      PODMAN_COMPOSE_WARNING_LOGS = "false";
    };
  };

  home.file.".config/skhd/skhdrc".text = ''
    # Disable close window
    cmd - w : true
    # Hyper keymap
    :: hyper_mode
    f19 ; hyper_mode
    hyper_mode < e : skhd -k "q"; emacsclient --socket-name /var/folders/39/fty64sbs0h14_3bh2rqq7q9m0000gn/T/emacs501/default -n -c
    hyper_mode < j : skhd -k "q"; emacsclient --socket-name /var/folders/39/fty64sbs0h14_3bh2rqq7q9m0000gn/T/emacs501/default -n -c -F '((name . "org-protocol-capture"))' 'org-protocol://capture?template=j'
    hyper_mode < t : skhd -k "q"; alacritty
    hyper_mode < q ; default
    hyper_mode < f19 ; default
  '';

  home.shellAliases = {
    ec = "emacsclient --socket-name /var/folders/39/fty64sbs0h14_3bh2rqq7q9m0000gn/T/emacs501/default -n -c";
    pm = "podman";
  };

  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    extraConfig = "UseKeychain = yes";
    matchBlocks."*" = {
      addKeysToAgent = "yes";
    };
  };

  programs.starship = {
    enable = false;
    settings = {
      add_newline = false;
      package.disabled = true;
      directory.truncate_to_repo = false;
      git_commit.only_detached = false;
      status = {
        disabled = false;
        symbol = "";
      };
    };
  };

  services.podman = {
    enable = true;
    settings = {
      containers = {
        # machine = {
        #  provider = "libkrun";
        # };
        engine = {
          compose_providers = [ "${pkgs.docker-compose}/bin/docker-compose" ];
        };
      };
    };
  };

  targets.darwin.linkApps.enable = false;
}
