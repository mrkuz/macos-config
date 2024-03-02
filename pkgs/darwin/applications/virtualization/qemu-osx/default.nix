{ stdenv, lib, pkgs, sources, ... }:
let
  source = sources.qemu;
in stdenv.mkDerivation rec {
  name = "qemu-osx";
  src = source;

  nativeBuildInputs = with pkgs; [ pkg-config ninja python3Packages.python ];
  buildInputs = with pkgs; [ glib pixman
    darwin.stubs.rez
    darwin.stubs.setfile
    darwin.sigtool
    darwin.apple_sdk.frameworks.CoreServices
    darwin.apple_sdk.frameworks.Cocoa
    darwin.apple_sdk.frameworks.Hypervisor
    darwin.apple_sdk.frameworks.vmnet
    libslirp
    SDL2
    libepoxy-angle
    virglrenderer-angle
  ];

  dontUseMesonConfigure = true;
  dontStrip = true;

  unpackPhase = ''
    tar xJf $src --strip-components=1
  '';

  patches = [ ./shader.patch ];

  configureFlags = [
    "--disable-strip"
    "--disable-tools"
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
    "--enable-sdl"
  ];
  preBuild = "cd build";

  meta = with lib; {
    platforms = platforms.darwin;
  };
}
