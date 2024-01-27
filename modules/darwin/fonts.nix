{ config, pkgs, lib, nixpkgs, self, ... }:
with lib;
let
  cfg = config.modules.fonts;
in
{
  options.modules.fonts = {
    enable = mkOption {
      default = false;
      type = types.bool;
    };
  };

  config = mkIf cfg.enable {
    fonts = {
      fontDir.enable = true;
      fonts = with pkgs; [
        dejavu_fonts
        fira-code
        hack-font
        inconsolata
        source-code-pro
        ubuntu_font_family
      ];
    };
  };
}
