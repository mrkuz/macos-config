{ config, lib, pkgs, ... }:
with lib;
let
  cfg = config.modules.tmux;
in
{
  options.modules.tmux = {
    enable = mkOption {
      default = false;
      type = types.bool;
    };
    shell = mkOption {
      default = "${pkgs.zsh}/bin/zsh";
      type = types.str;
    };
  };

  config = mkIf cfg.enable {
    programs.tmux = {
      enable = true;
      baseIndex = 1;
      clock24 = true;
      mouse = true;
      shell = cfg.shell;
      terminal = "screen-256color";
      plugins = [ pkgs.tmuxPlugins.extrakto ];
      extraConfig = ''
        set -g default-command "${cfg.shell}"

        set -g status-left " #S:#I.#P | "
        set -g status-right "%Y/%m/%d %H:%M "
        set -g status-style "bg=default fg=yellow"

        # Add empty status line for padding
        set -Fg "status-format[1]" "#{status-format[0]}"
        set -g "status-format[0]" ""
        set -g status 2

        # Show activity notification for other windows
        setw -g monitor-activity on
        set -g activity-action other
        set -g visual-activity on

        # Show bell notification for all windows
        setw -g monitor-bell on
        set -g bell-action any
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
  };
}
