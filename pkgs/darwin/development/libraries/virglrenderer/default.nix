{ stdenv, lib, pkgs, sources, ... }:
let
  source = sources.virglrenderer;
in stdenv.mkDerivation rec {
  name = "virglrenderer-angle";
  src = source;

  nativeBuildInputs = with pkgs; [ meson ninja python3 pkg-config ];
  buildInputs = with pkgs; [ libepoxy-angle ];

  mesonFlags = [
    "-Ddrm=disabled"
  ];

  meta = with lib; {
    platforms = platforms.darwin;
  };
}
