{ config, lib, pkgs, nixpkgs, vars, ... }:
{
  modules = {
    nix.enable = true;
    minimize.enable = false;
    qemuGuest = {
      autoLogin = true;
      dhcp = true;
      graphics = true;
      opengl = true;
      socketVmnet = true;
      user = vars.primaryUser;
    };
  };

  documentation = {
    doc.enable = false;
    info.enable = false;
    nixos.enable = false;
  };

  environment.sessionVariables = {
    WLR_NO_HARDWARE_CURSORS = "1";
    NIXOS_OZONE_WL = "1";
  };

  environment.systemPackages = with pkgs; [
    firefox-devedition
    mesa-demos
    # Sway
    sway
    wlr-randr
  ];

  fonts.packages = with pkgs; [
    ubuntu_font_family
  ];

  # programs.fish.enable = true;
  security.polkit.enable = true;

  services.greetd = {
    enable = true;
    settings = rec {
      initial_session = {
        command = "${pkgs.sway}/bin/sway";
        user = vars.primaryUser;
      };
      default_session = initial_session;
    };
  };

  users.users."${vars.primaryUser}" = {
    password = vars.primaryUser;
  };

  home-manager.users."${vars.primaryUser}" = {
    imports = [ ../../../users/common/markus.nix ];

    home.pointerCursor = {
       package = pkgs.yaru-theme;
       name = "Yaru";
    };

    programs.alacritty = {
      settings = {
        font = {
          normal = {
            family = "Ubuntu Mono";
            style = "Regular";
          };
          size = 12;
          offset = { x = 0; y = 4; };
          glyph_offset = { x = 0; y = 2; };
        };
      };
    };

    wayland.windowManager.sway = {
      enable = true;
      config = {
        defaultWorkspace = "workspace number 1";
        terminal = "${pkgs.alacritty}/bin/alacritty";
        fonts = {
          names = [ "Ubuntu Mono" ];
          size = 12.0;
        };
        bars = [
          {
            position = "top";
            statusCommand = null;
          }
        ];
        startup = [
          { command = "${pkgs.swaybg}/bin/swaybg -i ${pkgs.sway}/share/backgrounds/sway/Sway_Wallpaper_Blue_2048x1536.png"; }
        ];
      };
    };
  };
}
