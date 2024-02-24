{
  inputs = {
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    nixpkgs-darwin.url = "github:nixos/nixpkgs/nixpkgs-23.11-darwin";
    nixos-stable.url = "github:nixos/nixpkgs/nixos-23.11";
    flake-compat.url = "https://flakehub.com/f/edolstra/flake-compat/1.tar.gz";
    nix-darwin = {
      url = "github:LnL7/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    nix-homebrew = {
      url = "github:zhaofengli-wip/nix-homebrew";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    emacs-overlay = {
      url = "github:nix-community/emacs-overlay";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    apple-silicon = {
      url = "github:tpwrules/nixos-apple-silicon";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
  };

  outputs = { self, ... } @ inputs:
    let
      nixpkgs = inputs.nixpkgs-unstable;
      utils = {
        attrsToValues = attrs:
          nixpkgs.lib.attrsets.mapAttrsToList (name: value: value) attrs;

        mkPkgs = system: nixpkgs: import nixpkgs {
          inherit system;
          config.allowUnfree = true;
          overlays = [
            inputs.emacs-overlay.overlay
            inputs.apple-silicon.overlays.apple-silicon-overlay
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
        nixos.stableVersion = "23.11";
        rev = self.rev or self.dirtyRev or "dirty";
      };

      pkgs = utils.mkPkgs vars.currentSystem nixpkgs;
    in
    {
      inherit vars;

      nixosConfigurations.vm = nixpkgs.lib.nixosSystem {
        specialArgs = {
          inherit self nixpkgs;
          systemName = "vm";
          pkgs-stable = utils.mkPkgs "aarch64-linux" inputs.nixos-stable;
        };
        modules = [
          ./profiles/nixos/qemu-vm.nix
          {
            nixpkgs.pkgs = utils.mkPkgs "aarch64-linux" nixpkgs;
          }
          {
            virtualisation = {
              host.pkgs = pkgs;
              diskImage = null;
              # diskSize = 10240;
              cores = 2;
              memorySize = 4096;
              forwardPorts = [
                # openssh
                { from = "host"; host.port = 2201; guest.port = 22; }
                # docker
                { from = "host"; host.port = 2375; guest.port = 2375; }
                # k3s
                { from = "host"; host.port = 6443; guest.port = 6443; }
              ];
              graphics = false;
              # graphics = true;
              # resolution = { x = 1600; y = 1200; };
              # qemu.networkingOptions = [
              #   "-device virtio-net-device,netdev=net.0"
              #   "-netdev vmnet-shared,id=net.0,\${QEMU_NET_OPTS:+,$QEMU_NET_OPTS}"
              # ];
            };
          }
          inputs.home-manager.nixosModules.home-manager
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
          ./hosts/nixos/vm.nix
        ] ++ utils.attrsToValues self.nixosModules;
      };

      nixosConfigurations.qcow2 = nixpkgs.lib.nixosSystem {
        specialArgs = {
          inherit self nixpkgs;
          systemName = "image";
        };
        modules = [
          ./profiles/nixos/qemu-qcow2.nix
          {
            nixpkgs.pkgs = utils.mkPkgs "aarch64-linux" nixpkgs;
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

          qcow2 = import "${nixpkgs}/nixos/lib/make-disk-image.nix" {
            lib = nixpkgs.lib;
            config = self.nixosConfigurations.qcow2.config;
            pkgs = utils.mkPkgs "aarch64-linux";
            diskSize = "auto";
            format = "qcow2";
            partitionTableType = "efi";
            # Defaults
            installBootLoader = true;
            onlyNixStore = false;
            label = "nixos";
            additionalSpace = "512M";
            # Custom
            copyChannel = false;
          };
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
