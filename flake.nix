{
  inputs = {
    nixpkgs.url = "nixpkgs/nixpkgs-unstable";
    # nixpkgs.url = "nixpkgs/nixpkgs-23.05-darwin";
    nix-darwin = {
      url = "github:LnL7/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, nix-darwin, } @ inputs: {
    darwinConfigurations."m3" = nix-darwin.lib.darwinSystem {
      specialArgs = { inherit self; };
      modules = [
        ./configuration.nix
      ];
    };
  };
}
