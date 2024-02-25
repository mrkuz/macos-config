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
      lib = utils.extendLib nixpkgs.lib;
      pkgs = utils.mkPkgs {};

      vars = {
        currentSystem = "aarch64-darwin";
        primaryUser = "markus";
        darwin.stateVersion = 4;
        homeManager.stateVersion = "23.11";
        nixos.stateVersion = "24.05";
        nixos.stableVersion = "23.11";
        rev = self.rev or self.dirtyRev or "dirty";
      };

      utils = {
        attrsToValues = attrs:
          lib.attrsets.mapAttrsToList (name: value: value) attrs;

        extendLib = lib: lib.extend(self: super: {
          vmAttrs = options: block: if (builtins.hasAttr "cores" options.virtualisation) then block else {};
        });

        mkPkgs = { system ? vars.currentSystem, nixpkgs ? inputs.nixpkgs-unstable } : import nixpkgs {
          inherit system;
          config.allowUnfree = true;
          overlays = [
            inputs.emacs-overlay.overlay
            inputs.apple-silicon.overlays.apple-silicon-overlay
            (_: super: self.packages."${system}")
          ] ++ utils.attrsToValues self.overlays;
        };

        mkHomeManagerModule = { version ? vars.homeManager.stateVersion }: {
          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;
            #  extraSpecialArgs = { inherit self; };
            sharedModules = [
              { home.stateVersion = version; }
            ] ++ utils.attrsToValues self.homeManagerModules;
          };
        };

        mkVm = { name, targetSystem ? vars.currentSystem, hostPkgs ? pkgs, profile ? ./profiles/nixos/qemu-vm.nix }: lib.nixosSystem {
          specialArgs = {
            inherit self nixpkgs;
            systemName = name;
            pkgsStable = utils.mkPkgs { system  = targetSystem; nixpkgs = inputs.nixos-stable; };
          };
          modules = [
            profile
            ({ lib, options, ... }:  {
              networking.hostName = lib.mkDefault name;
              nixpkgs.pkgs = utils.mkPkgs { system = targetSystem; };
              modules.qemuGuest.enable = true;
              virtualisation = lib.vmAttrs options {
                host.pkgs = hostPkgs;
              };

              system = {
                inherit name;
                stateVersion = vars.nixos.stateVersion;
                configurationRevision = vars.rev;
              };
            })
            inputs.home-manager.nixosModules.home-manager (utils.mkHomeManagerModule {})
            (./hosts/nixos/vm + "/${name}.nix")
          ] ++ utils.attrsToValues self.nixosModules;
        };
      };
    in
    {
      inherit vars;

      nixosConfigurations.playground-vm = utils.mkVm { name = "playground"; targetSystem = "aarch64-linux"; };
      nixosConfigurations.toolbox-vm = utils.mkVm { name = "toolbox"; targetSystem = "aarch64-linux"; };
      nixosConfigurations.docker-vm = utils.mkVm { name = "docker"; targetSystem = "aarch64-linux"; };
      nixosConfigurations.desktop-vm = utils.mkVm { name = "desktop"; targetSystem = "aarch64-linux"; };
      nixosConfigurations.playground-qcow2 = utils.mkVm { name = "playground"; targetSystem = "aarch64-linux"; profile = ./profiles/nixos/qemu-qcow2.nix; };

      darwinConfigurations."m3" = inputs.nix-darwin.lib.darwinSystem {
        specialArgs = { inherit self nixpkgs; };
        modules = [
          { nixpkgs.pkgs = pkgs; }
          inputs.home-manager.darwinModules.home-manager (utils.mkHomeManagerModule {})
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
          # options.json
          home-manager-options-json = inputs.home-manager.packages.aarch64-darwin.docs-json;
          nixos-options-json = (lib.nixosSystem { modules = [ { nixpkgs.pkgs = pkgs; } ]; }).config.system.build.manual.optionsJSON;
          darwin-options-json = (inputs.nix-darwin.lib.darwinSystem { modules = [ { nixpkgs.pkgs = pkgs; } ]; }).config.system.build.manual.optionsJSON;
          # VMs
          playground-vm = self.nixosConfigurations.playground-vm.config.system.build.vm;
          toolbox-vm = self.nixosConfigurations.toolbox-vm.config.system.build.vm;
          docker-vm = self.nixosConfigurations.docker-vm.config.system.build.vm;
          desktop-vm = self.nixosConfigurations.desktop-vm.config.system.build.vm;
          # QCOW2 images
          playground-qcow2 = import "${nixpkgs}/nixos/lib/make-disk-image.nix" {
            inherit lib;
            config = self.nixosConfigurations.playground-qcow2.config;
            pkgs = utils.mkPkgs { system = "aarch64-linux"; };
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
        minimize = import ./modules/nixos/minimize.nix;
        nix = import ./modules/nixos/nix.nix;
        qemu-quest = import ./modules/nixos/qemu-guest.nix;
      };

      overlays = {
        nixos-option = import ./overlays/tools/nix/nixos-option;
        lib = self: super: {
          lib = utils.extendLib super.lib;
        };
      };
    };
}
