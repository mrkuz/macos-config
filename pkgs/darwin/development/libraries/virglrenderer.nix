{ stdenv, lib, pkgs, sources, ... }:
let
  source = sources.virglrenderer-akihikodaki;
  # source = sources.virglrenderer-utm;
in stdenv.mkDerivation rec {
  name = "virglrenderer";
  src = source;

  nativeBuildInputs = with pkgs; [ meson ninja python3 pkg-config ];
  buildInputs = with pkgs; [ macos.angle macos.libepoxy ];

  # mesonFlags = [
  #   "-Ddrm=disabled"
  # ];

  meta = with lib; {
    platforms = platforms.darwin;
  };
}
