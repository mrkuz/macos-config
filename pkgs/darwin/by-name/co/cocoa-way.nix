{
  stdenv,
  lib,
  pkgs,
  sources,
  ...
}:
let
  source = sources.cocoa-way;
in
stdenv.mkDerivation rec {
  name = "cocoa-way";
  src = source;

  cargoDeps = pkgs.rustPlatform.fetchCargoVendor {
    src = source;
    hash = "sha256-zj8Zks7u8G13s/u5tOImWnJTpVOYOo8PBUpiiRcoAgQ=";
  };

  nativeBuildInputs = with pkgs; [
    pkg-config
    cargo
    rustPlatform.cargoSetupHook
  ];

  buildInputs = with pkgs; [
    libxkbcommon
    pixman
  ];

  runtimeDependencies = with pkgs; [
    macos.waypipe
  ];

  buildPhase = ''
    runHook preBuild
    cargo build --release
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    mkdir -p $out/bin
    cp target/release/cocoa-way $out/bin/
    cp run_waypipe.sh $out/bin/run_waypipe
    runHook postInstall
  '';

  meta = with lib; {
    platforms = platforms.darwin;
  };
}
