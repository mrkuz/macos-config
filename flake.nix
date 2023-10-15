{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nix-darwin = {
      url = "github:LnL7/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-homebrew = {
      url = "github:zhaofengli-wip/nix-homebrew";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    emacs-overlay = {
      url = "github:nix-community/emacs-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, ... } @ inputs:
    let
      utils = {
        attrsToValues = attrs:
          nixpkgs.lib.attrsets.mapAttrsToList (name: value: value) attrs;
      };
    in
    {
      darwinConfigurations."m3" = inputs.nix-darwin.lib.darwinSystem {
        specialArgs = { inherit self nixpkgs; };
        modules = [
          {
            nixpkgs = {
              config.allowUnfree = true;
              overlays = [ inputs.emacs-overlay.overlay ];
              hostPlatform = "aarch64-darwin";
            };

            system = {
              configurationRevision = self.rev or self.dirtyRev or null;
              stateVersion = 4;
            };
          }
          inputs.home-manager.darwinModules.home-manager
          {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              #  extraSpecialArgs = { inherit self; };
              sharedModules = [
                {
                  home.stateVersion = "23.05";
                }
              ] ++ utils.attrsToValues self.homeManagerModules;
            };
          }
          inputs.nix-homebrew.darwinModules.nix-homebrew
          {
            nix-homebrew = {
              enable = true;
              enableRosetta = false;
              user = "markus";
            };
          }
          ./hosts/m3/configuration.nix
        ] ++ utils.attrsToValues self.darwinModules;
      };

      darwinModules = {
        fonts = import ./modules/darwin/fonts.nix;
        hunspell = import ./modules/darwin/hunspell.nix;
        nix = import ./modules/darwin/nix.nix;
      };

      homeManagerModules = {
        emacs = import ./modules/home-manager/emacs.nix;
        kitty = import ./modules/home-manager/kitty.nix;
        tmux = import ./modules/home-manager/tmux.nix;
      };
    };
}
