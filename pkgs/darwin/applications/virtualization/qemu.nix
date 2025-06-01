{ stdenv, darwinMinVersionHook, lib, pkgs, sources, ... }:
let
  source = sources.qemu;
  darwinSDK = [ pkgs.apple-sdk_13 (darwinMinVersionHook "13") ];
in stdenv.mkDerivation rec {
  name = "qemu";
  src = source;

  nativeBuildInputs = with pkgs; [ pkg-config ninja python3Packages.python ];
  buildInputs = with pkgs; [
    dtc
    glib
    libslirp
    pixman
    darwin.sigtool
    darwinSDK
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
  patches = [
    ./qemu/akihikodaki-10.0.0.patch
    ./qemu/skip-macos-icon.patch
  ];
  # patches = [ ./qemu/utm-9.1.0.patch ];

  configureFlags = [
    "--disable-strip"
    "--target-list=aarch64-softmmu"
    "--disable-dbus-display"
    "--disable-plugins"
    "--enable-slirp"
    "--enable-tcg"
    "--enable-virtfs"
    # MacOS
    "--enable-cocoa"
    "--enable-hvf"
    "--enable-vmnet"
    "--enable-pvg"
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
