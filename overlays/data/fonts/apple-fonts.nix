inputs: final: prev:
{
  inherit (inputs.apple-fonts.packages.${prev.stdenv.hostPlatform.system})
    sf-mono
    sf-mono-nerd
    ;
}
