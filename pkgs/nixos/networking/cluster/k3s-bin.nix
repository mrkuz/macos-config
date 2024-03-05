{ stdenv, lib, pkgs, sources, ... }:
let
  source = sources.k3s-aarch64-linux;
in stdenv.mkDerivation rec {
  name = "k3s-bin";
  src = source;

  dontUnpack = true;

  installPhase = ''
    runHook preInstall
    mkdir -p $out/bin
    install -m755 $src $out/bin/k3s
    ln -s k3s $out/bin/containerd
    ln -s k3s $out/bin/crictl
    ln -s k3s $out/bin/ctr
    ln -s k3s $out/bin/k3s-agent
    ln -s k3s $out/bin/k3s-certificate
    ln -s k3s $out/bin/k3s-completion
    ln -s k3s $out/bin/k3s-etcd-snapshot
    ln -s k3s $out/bin/k3s-secrets-encrypt
    ln -s k3s $out/bin/k3s-server
    ln -s k3s $out/bin/k3s-token
    ln -s k3s $out/bin/kubectl
    runHook postInstall
  '';

  meta = with lib; {
    platforms = [ "aarch64-linux" ];
  };
}
