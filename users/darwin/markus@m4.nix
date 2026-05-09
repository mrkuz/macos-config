{
  config,
  lib,
  pkgs,
  systemName,
  ...
}:
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
      # Virtualization & containers
      docker
      kubectl
      lima
      macos.qemu
    ];
    sessionVariables = {
      CLICOLOR = "1";
      # HOMEBREW_NO_ENV_HINTS = "1";
      # HOMEBREW_NO_AUTO_UPDATE = "1";
      PODMAN_COMPOSE_WARNING_LOGS = "false";
    };
  };

  programs = {
    # docker-cli.enable = true;
    uv.enable = true;
    vscode.enable = true;
  };

  programs.claude-code = {
    enable = true;
    package = pkgs.claude-code;
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

  services.podman = {
    enable = true;
    useDefaultMachine = false;
    settings = {
      containers = {
        engine = {
          compose_providers = [ "${pkgs.podman-compose}/bin/podman-compose" ];
        };
      };
    };
  };

  targets.darwin.linkApps.enable = false;
}
