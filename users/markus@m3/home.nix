{ config, pkgs, ... }:
{
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
      shell = "${pkgs.fish}/bin/fish -il";
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
      emacs-unstable
      rectangle
    ];
  };
}
