{ stdenv, lib, pkgs, sources, ... }:
let
  source = sources.libepoxy;
in stdenv.mkDerivation rec {
  name = "libepoxy";
  src = source;

  nativeBuildInputs = with pkgs; [ meson ninja python3 pkg-config ];
  buildInputs = with pkgs; [ macos.angle ];

  patches = [
    # See: https://github.com/NixOS/nixpkgs/blob/79baff8812a0d68e24a836df0a364c678089e2c7/pkgs/development/libraries/libepoxy/default.nix#L27
    ./libepoxy/libgl-path.patch
    # See: https://gist.github.com/akihikodaki/87df4149e7ca87f18dc56807ec5a1bc5
    ./libepoxy/akihikodaki.patch
  ];

  postPatch = ''
    patchShebangs src/*.py
  '';

  mesonFlags = [
    "-Degl=yes"
  ];

  env.NIX_CFLAGS_COMPILE = ''-DLIBGL_PATH="${lib.getLib pkgs.macos.angle}/lib"'';

  meta = with lib; {
    platforms = platforms.darwin;
  };
}
