{
  stdenv,
  lib,
  pkgs,
  sources,
  ...
}:
let
  source = sources.waypipe-darwin;
in
stdenv.mkDerivation rec {
  name = "waypipe-darwin";
  src = source;

  cargoDeps = pkgs.rustPlatform.fetchCargoVendor {
    src = source;
    hash = "sha256-gsKxdvseabVWq9SpdsxRtb4LQmMOw1RxpGLpAUvjE6s=";
  };

  nativeBuildInputs = with pkgs; [
    meson
    ninja
    pkg-config
    cargo
    rust-bindgen
    # shaderc
    scdoc
    rustPlatform.cargoSetupHook
  ];

  buildInputs = with pkgs; [
    lz4
    zstd
    # vulkan-headers
    # vulkan-loader
  ];

  # runtimeDependencies = with super.pkgs; [
  #   vulkan-loader
  # ];

  mesonFlags = [
    "-Dwith_gbm=disabled"
    "-Dwith_dmabuf=disabled"
    "-Dwith_video=disabled"
  ];

  meta = with lib; {
    platforms = platforms.darwin;
  };
}
