{
  inputs = {
    mrkuz.url = "github:mrkuz/macos-config";
  };
  outputs = { self, mrkuz, ... } @ inputs:
    let
      name = "nixos-vm";
      system = "aarch64-darwin";
    in {
      nixosConfigurations."${name}" = mrkuz.utils.mkVm {
        inherit name;
        targetSystem = "aarch64-linux";
        configuration = ./configuration.nix;
      };
      packages."${system}".default = self.nixosConfiguratins."${name}".config.system.build.startVm;
    };
}
