{ config, pkgs, ... }:
{
  home.sessionVariables = {
    HOMEBREW_BUNDLE_FILE = "/Users/markus/etc/config.git/var/Brewfile";
    # SHELL = "${pkgs.fish}/bin/fish";
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
      gdc = "git diff --cached";
      gs = "git status";
    };
    interactiveShellInit = ''
      set -U fish_greeting
    '';
  };

  programs.fzf = {
    enable = true;
    enableFishIntegration = true;
  };

  programs.tmux = {
    enable = true;
    baseIndex = 1;
    clock24 = true;
    mouse = true;
    shell = "${pkgs.fish}/bin/fish";
    terminal = "screen-256color";
    extraConfig = ''
      set -g default-command "${pkgs.fish}/bin/fish"

      set -g status-left " #S:#I.#P | "
      set -g status-right "%Y/%m/%d %H:%M "

      # Show activity notification for other windows
      setw -g monitor-activity on
      set -g visual-activity on

      # Show bell notification for all windows
      setw -g monitor-bell on
      set -g visual-bell on

      # Keep notifications until key is pressed
      set -g display-time 0

      # Emacs-like pane management
      bind ")" kill-pane
      bind "!" break-pane
      bind "@" split-window -v
      bind "#" split-window -h

      # Other key bindings
      bind C-b last-window
      bind b choose-window
      bind R command-prompt -p "Rename window:" "rename-window '%%'"
      bind C-k confirm -p "Kill pane? [y/n]" kill-pane
      bind C-s setw -g synchronize-panes
    '';
  };

  programs.kitty = {
    enable = true;
    shellIntegration = {
      enableFishIntegration = true;
      mode = "no-cursor";
    };
    theme = "Solarized Dark - Patched";
    font = {
      name = "SF Mono";
      size = 14;
    };
    settings = {
      cursor_shape = "block";
      cursor_blink_interval = 0;
      copy_on_select = "clipboard";
      mouse_hide_wait = 0;
      shell = "${pkgs.tmux}/bin/tmux";
      strip_trailing_spaces = "smart";
    };
  };

  programs.git = {
    enable = true;
    userName = "mrkuz";
    userEmail = "markus@bitsandbobs.net";
    diff-so-fancy.enable = true;
  };

  launchd = {
    enable = true;
    agents = {
      emacs = {
        enable = true;
        config = {
          ProgramArguments = [ "${pkgs.emacs-unstable}/bin/emacs" "--daemon=default" ];
          RunAtLoad = true;
          # KeepAlive = true;
          # StandardOutPath = "/tmp/emacs.stdout";
          # StandardErrorPath = "/tmp/emacs.stderr";
        };
      };
    };
  };

  services.syncthing.enable = true;

  home = {
    packages = with pkgs; [
      # Emacs
      emacs-unstable
      # MacOS
      mas
      rectangle
      # CLI utils
      age
      bat
      fd
      htop
      iftop
      jq
      ncdu
      pdftk
      pwgen
      rclone
      ripgrep
      socat
      tree
      wget
    ];
  };
}
