{ stdenv, overrideSDK, lib, pkgs, sources, ... }:
let
  source = sources.qemu;
  stdenv123 = overrideSDK stdenv {
    darwinSdkVersion = "12.3";
    darwinMinVersion = "12.0";
  };
in stdenv123.mkDerivation rec {
  name = "qemu";
  src = source;

  nativeBuildInputs = with pkgs; [ pkg-config ninja python3Packages.python ];
  buildInputs = with pkgs; [
    dtc
    glib
    libslirp
    pixman
    darwin.stubs.rez
    darwin.stubs.setfile
    darwin.sigtool
    darwin.apple_sdk_12_3.frameworks.CoreServices
    darwin.apple_sdk_12_3.frameworks.Cocoa
    darwin.apple_sdk_12_3.frameworks.Hypervisor
    darwin.apple_sdk_12_3.frameworks.Kernel
    darwin.apple_sdk_12_3.frameworks.vmnet
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
