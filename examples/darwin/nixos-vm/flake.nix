{
  inputs = {
    mrkuz.url = "github:mrkuz/macos-config";
    flake-compat.url = "https://flakehub.com/f/edolstra/flake-compat/1.tar.gz";
  };
  outputs = { self, mrkuz, ... } @ inputs:
    let
      name = "nixos-vm";
      system = "aarch64-darwin";
    in {
      nixosConfigurations."${name}" = mrkuz.utils.mkVm {
        inherit name;
        selfReference = self;
        targetSystem = "aarch64-linux";
        configuration = ./configuration.nix;
      };
      packages."${system}".default = self.nixosConfigurations."${name}".config.system.build.startVm;
    };
}
