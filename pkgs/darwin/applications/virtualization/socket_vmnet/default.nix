{ stdenv, lib, pkgs, sources, ... }:
let
  source = sources.socket_vmnet;
in stdenv.mkDerivation rec {
  name = "socket_vmnet";
  src = source;
  buildInputs = [ pkgs.darwin.apple_sdk.frameworks.vmnet ];

  installPhase = ''
    runHook preInstall
    make DESTDIR=$out PREFIX=/ install.bin
    mkdir -p $out/Library/LaunchDaemons/
    make DESTDIR=$out PREFIX=$out install.launchd.plist
    runHook postInstall
  '';

  meta = with lib; {
    description = source.description;
    homepage = source.homepage;
    platforms = platforms.darwin;
  };
}
