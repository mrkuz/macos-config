{ stdenv, lib, pkgs, sources, ... }:
let
  source = sources.angle;
in stdenv.mkDerivation rec {
  name = "angle";
  src = source;

  nativeBuildInputs = with pkgs; [ unzip ];

  buildPhase = ''
    unzip ${sources.chromium}
  '';

  installPhase = ''
    mkdir -p $out/lib
    cp chrome-mac/Chromium.app/Contents/Frameworks/Chromium\ Framework.framework/Libraries/libEGL.dylib $out/lib/
    cp chrome-mac/Chromium.app/Contents/Frameworks/Chromium\ Framework.framework/Libraries/libGLESv2.dylib $out/lib/
    cp -r include $out
  '';

  meta = with lib; {
    platforms = platforms.darwin;
  };
}
