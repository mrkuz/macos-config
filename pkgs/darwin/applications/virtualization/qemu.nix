{ stdenv, lib, pkgs, sources, ... }:
let
  source = sources.qemu;
in stdenv.mkDerivation rec {
  name = "qemu";
  src = source;

  nativeBuildInputs = with pkgs; [ pkg-config ninja python3Packages.python ];
  buildInputs = with pkgs; [
    glib
    libslirp
    pixman
    darwin.stubs.rez
    darwin.stubs.setfile
    darwin.sigtool
    darwin.apple_sdk.frameworks.CoreServices
    darwin.apple_sdk.frameworks.Cocoa
    darwin.apple_sdk.frameworks.Hypervisor
    darwin.apple_sdk.frameworks.vmnet
    # SDL2
    macos.angle
    macos.libepoxy
    macos.virglrenderer
  ];

  dontUseMesonConfigure = true;
  dontStrip = true;

  unpackPhase = ''
    runHook preUnpack
    tar xJf $src --strip-components=1
    runHook postUnpack
  '';

  # See: https://gist.github.com/akihikodaki/87df4149e7ca87f18dc56807ec5a1bc5
  patches = [ ./qemu/akihikodaki.patch ];

  configureFlags = [
    "--disable-strip"
    "--target-list=aarch64-softmmu"
    "--disable-dbus-display"
    "--enable-slirp"
    "--enable-tcg"
    "--enable-virtfs"
    # MacOS
    "--enable-cocoa"
    "--enable-hvf"
    "--enable-vmnet"
    # OpenGL
    "--enable-opengl"
    "--enable-virglrenderer"
    # "--enable-sdl"
  ];
  preBuild = "cd build";

  env.NIX_CFLAGS_COMPILE = "-Wno-error=implicit-function-declaration";

  meta = with lib; {
    platforms = platforms.darwin;
  };
}
