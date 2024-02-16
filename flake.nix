{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-compat.url = "https://flakehub.com/f/edolstra/flake-compat/1.tar.gz";
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

        mkPkgs = system: import nixpkgs {
          inherit system;
          config.allowUnfree = true;
          overlays = [
            inputs.emacs-overlay.overlay
            (_: super: self.packages."${system}")
          ] ++ utils.attrsToValues self.overlays;
        };
      };

      vars = {
        currentSystem = "aarch64-darwin";
        primaryUser = "markus";
        darwin.stateVersion = 4;
        homeManager.stateVersion = "23.11";
        nixos.stateVersion = "24.05";
        rev = self.rev or self.dirtyRev or "dirty";
      };

      pkgs = utils.mkPkgs vars.currentSystem;
    in
    {
      inherit vars;

      nixosConfigurations.vm = nixpkgs.lib.nixosSystem {
        specialArgs = {
          inherit self nixpkgs;
          systemName = "vm";
        };
        modules = [
          "${nixpkgs}/nixos/modules/virtualisation/qemu-vm.nix"
          {
            nixpkgs.pkgs = utils.mkPkgs "aarch64-linux";
            virtualisation.host.pkgs = pkgs;
          }
          ./hosts/nixos/vm.nix
        ] ++ utils.attrsToValues self.nixosModules;
      };

      darwinConfigurations."m3" = inputs.nix-darwin.lib.darwinSystem {
        specialArgs = { inherit self nixpkgs; };
        modules = [
          { nixpkgs.pkgs = pkgs; }
          inputs.home-manager.darwinModules.home-manager
          {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              #  extraSpecialArgs = { inherit self; };
              sharedModules = [
                { home.stateVersion = vars.homeManager.stateVersion; }
              ] ++ utils.attrsToValues self.homeManagerModules;
            };
          }
          inputs.nix-homebrew.darwinModules.nix-homebrew
          {
            nix-homebrew = {
              enable = true;
              enableRosetta = false;
              user = vars.primaryUser;
            };
          }
          ./hosts/darwin/m3.nix
        ] ++ utils.attrsToValues self.darwinModules;
      };

      packages = {
        aarch64-darwin = {
          vm = self.nixosConfigurations.vm.config.system.build.vm;
          # options.json
          home-manager-options-json = inputs.home-manager.packages.aarch64-darwin.docs-json;
          nixos-options-json = (nixpkgs.lib.nixosSystem {
            modules = [ { nixpkgs.pkgs = pkgs; } ];
          }).config.system.build.manual.optionsJSON;
          darwin-options-json = (inputs.nix-darwin.lib.darwinSystem {
            modules = [ { nixpkgs.pkgs = pkgs; } ];
          }).config.system.build.manual.optionsJSON;
        };
        aarch64-linux = {};
      };

      darwinModules = {
        fonts = import ./modules/darwin/fonts.nix;
        hunspell = import ./modules/darwin/hunspell.nix;
        nix = import ./modules/darwin/nix.nix;
        tuptime = import ./modules/darwin/tuptime.nix;
      };

      homeManagerModules = {
        emacs = import ./modules/home-manager/emacs.nix;
        kitty = import ./modules/home-manager/kitty.nix;
        tmux = import ./modules/home-manager/tmux.nix;
      };

      nixosModules = {
        nix = import ./modules/nixos/nix.nix;
      };

      overlays = {
        nixos-option = import ./overlays/tools/nix/nixos-option;
      };
    };
}
