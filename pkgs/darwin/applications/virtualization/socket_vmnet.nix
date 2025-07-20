{ stdenv, lib, pkgs, sources, ... }:
let
  source = sources.socket_vmnet;
in stdenv.mkDerivation rec {
  name = "socket_vmnet";
  src = source;
  buildInputs = [ pkgs.util-linux ];

  installPhase = ''
    runHook preInstall
    make DESTDIR=$out PREFIX=/ install.bin
    mkdir -p $out/Library/LaunchDaemons/
    make DESTDIR=$out PREFIX=$out install.launchd.plist
    runHook postInstall
  '';

  meta = with lib; {
    platforms = platforms.darwin;
  };
}
