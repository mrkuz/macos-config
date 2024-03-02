{ stdenv, lib, pkgs, sources, ... }:
let
  source = sources.libepoxy-angle;
in stdenv.mkDerivation rec {
  name = "libepoxy-angle";
  src = source;

  nativeBuildInputs = with pkgs; [ meson ninja python3 pkg-config ];
  buildInputs = with pkgs; [ darwin.apple_sdk.frameworks.Carbon angle ];
  propagatedBuildInputs = with pkgs; [ angle ];

  # See: https://github.com/NixOS/nixpkgs/blob/79baff8812a0d68e24a836df0a364c678089e2c7/pkgs/development/libraries/libepoxy/default.nix#L27
  patches = [ ./libgl-path.patch ];

  postPatch = ''
    patchShebangs src/*.py
  '';

  mesonFlags = [
    "-Degl=yes"
  ];

  env.NIX_CFLAGS_COMPILE = ''-DLIBGL_PATH="${lib.getLib pkgs.angle}/lib"'';

  meta = with lib; {
    platforms = platforms.darwin;
  };
}
