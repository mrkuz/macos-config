{
  inputs = {
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    # nixpkgs-darwin.url = "github:nixos/nixpkgs/nixpkgs-24.05-darwin";
    # nixpkgs-master.url = "github:nixos/nixpkgs/master";
    nixos-stable.url = "github:nixos/nixpkgs/nixos-24.05";
    flake-compat.url = "https://flakehub.com/f/edolstra/flake-compat/1.tar.gz";
    nix-alien = { url = "github:thiagokokada/nix-alien"; inputs.nixpkgs.follows = "nixpkgs-unstable"; };
    nix-darwin = { url = "github:LnL7/nix-darwin/master"; inputs.nixpkgs.follows = "nixpkgs-unstable"; };
    nix-homebrew = { url = "github:zhaofengli-wip/nix-homebrew"; inputs.nixpkgs.follows = "nixpkgs-unstable"; };
    home-manager = { url = "github:nix-community/home-manager"; inputs.nixpkgs.follows = "nixpkgs-unstable"; };
    emacs-overlay = { url = "github:nix-community/emacs-overlay"; inputs.nixpkgs.follows = "nixpkgs-unstable"; };
    apple-silicon = { url = "github:tpwrules/nixos-apple-silicon"; inputs.nixpkgs.follows = "nixpkgs-unstable"; };
  };

  outputs = { self, ... } @ inputs:
    let
      sources = import ./nix/sources.nix;
      nixpkgs = inputs.nixpkgs-unstable;
      lib = utils.extendLib nixpkgs.lib;
      pkgs = utils.mkPkgs {};
      pkgsLinux = utils.mkPkgs { system = "aarch64-linux"; };

      vars = {
        currentSystem = "aarch64-darwin";
        primaryUser = "markus";
        sshKeyFile = ./users/darwin/markus/files/id_rsa.pub;
      };

      versions = {
        darwin.stateVersion = 4;
        homeManager.stateVersion = "25.05";
        nixos.stateVersion = "25.05";
        nixos.stableVersion = "24.11";
        rev = self.rev or self.dirtyRev or "dirty";
      };

      utils = {
        attrsToValues = attrs:
          lib.attrsets.mapAttrsToList (name: value: value) attrs;

        extendLib = lib: lib.extend(self: super: {
          hm = inputs.home-manager.lib.hm;
          vmHostAttrs = options: block: if (builtins.hasAttr "cores" options.virtualisation) then block else {};
          buildQemuVm = { name, targetSystem, configuration }:
            (utils.mkVm { inherit name targetSystem configuration; }).config.system.build.startVm;
        });

        mkPkgs = { system ? vars.currentSystem, nixpkgs ? inputs.nixpkgs-unstable } : import nixpkgs {
          inherit system;
          config.allowUnfree = true;
          overlays = [
            inputs.emacs-overlay.overlay
            inputs.apple-silicon.overlays.apple-silicon-overlay
            inputs.nix-alien.overlays.default
            (_: super: self.packages."${system}")
          ] ++ utils.attrsToValues self.overlays;
        };

        callPkg = package:
          pkgs.callPackage package { inherit sources; };

        mkHomeManagerModule = { name, version ? versions.homeManager.stateVersion }: {
          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;
            extraSpecialArgs = {
              systemName = name;
              inherit lib;
              pkgsStable = utils.mkPkgs { nixpkgs = inputs.nixos-stable; };
            };
            sharedModules = [
              { home.stateVersion = version; }
            ] ++ utils.attrsToValues self.homeManagerModules;
          };
        };

        mkVm = {
          name,
          targetSystem ? vars.currentSystem,
          selfReference ? self,
          nixpkgs ? inputs.nixpkgs-unstable,
          hostPkgs ? pkgs,
          profile ? ./profiles/nixos/qemu-vm.nix,
          configuration ? { imports = [ (./hosts/nixos/vm + "/${name}.nix") ]; }
        } : lib.nixosSystem {
          specialArgs = {
            inherit vars versions nixpkgs;
            self = selfReference;
            systemName = name;
            pkgsStable = utils.mkPkgs { system = targetSystem; nixpkgs = inputs.nixos-stable; };
          };
          modules = [
            profile
            ({ lib, options, ... }:  {
              networking.hostName = lib.mkDefault name;
              nixpkgs.pkgs = utils.mkPkgs { system = targetSystem; inherit nixpkgs; };
              modules.qemuGuest.enable = true;
              virtualisation = lib.vmHostAttrs options {
                host.pkgs = hostPkgs;
              };

              system = {
                inherit name;
                stateVersion = versions.nixos.stateVersion;
                configurationRevision = versions.rev;
              };

              users.users.root.openssh.authorizedKeys.keyFiles = [ vars.sshKeyFile ];
            })
            inputs.home-manager.nixosModules.home-manager (utils.mkHomeManagerModule { inherit name; })
            configuration
          ] ++ utils.attrsToValues self.nixosModules;
        };

        mkDocker = {
          name,
          targetSystem ? vars.currentSystem,
          selfReference ? self,
          configuration ? { imports = [ (./hosts/nixos/vm + "/${name}.nix") ]; }
        } : lib.nixosSystem {
          specialArgs = {
            inherit vars versions nixpkgs;
            self = selfReference;
            systemName = name;
            pkgsStable = utils.mkPkgs { system  = targetSystem; nixpkgs = inputs.nixos-stable; };
          };
          modules = [
            ./profiles/nixos/docker-tar.nix
            ({ lib, options, ... }:  {
              networking.hostName = lib.mkDefault name;
              nixpkgs.pkgs = (utils.mkPkgs { system = targetSystem; });

              system = {
                inherit name;
                stateVersion = versions.nixos.stateVersion;
                configurationRevision = versions.rev;
              };
            })
            inputs.home-manager.nixosModules.home-manager (utils.mkHomeManagerModule { inherit name; })
            configuration
          ] ++ utils.attrsToValues self.nixosModules;
        };

        mkDarwin = { name }: inputs.nix-darwin.lib.darwinSystem {
          specialArgs = {
            inherit self vars versions nixpkgs;
            systemName = name;
            # pkgsStable = utils.mkPkgs { nixpkgs = inputs.nixos-stable; };
          };
          modules = [
            { nixpkgs.pkgs = pkgs; }
            inputs.home-manager.darwinModules.home-manager (utils.mkHomeManagerModule { inherit name; })
            inputs.nix-homebrew.darwinModules.nix-homebrew
            {
              nix-homebrew = {
                enable = true;
                enableRosetta = false;
                user = vars.primaryUser;
              };

              system = {
                stateVersion = versions.darwin.stateVersion;
                configurationRevision = versions.rev;
              };
            }
            (./hosts/darwin + "/${name}.nix")
          ] ++ utils.attrsToValues self.darwinModules;
        };
      };
    in
    {
      inherit utils;

      nixosConfigurations.playground = utils.mkVm { name = "playground"; targetSystem = "aarch64-linux"; };
      nixosConfigurations.toolbox = utils.mkVm { name = "toolbox"; targetSystem = "aarch64-linux"; };
      nixosConfigurations.docker = utils.mkVm { name = "docker"; targetSystem = "aarch64-linux"; };
      nixosConfigurations.gnome = utils.mkVm { name = "gnome"; targetSystem = "aarch64-linux"; };
      nixosConfigurations.firefox = utils.mkVm { name = "firefox"; targetSystem = "aarch64-linux"; };
      nixosConfigurations.k3s = utils.mkVm { name = "k3s"; targetSystem = "aarch64-linux"; };
      nixosConfigurations.playground-qcow2 = utils.mkVm { name = "playground"; targetSystem = "aarch64-linux"; profile = ./profiles/nixos/qemu-qcow2.nix; };

      darwinConfigurations."m3" = utils.mkDarwin { name = "m3"; };

      packages = {
        aarch64-darwin = {
          # options.json
          home-manager-options-json = inputs.home-manager.packages.aarch64-darwin.docs-json;
          nixos-options-json = (lib.nixosSystem { modules = [ { nixpkgs.pkgs = pkgs; } ]; }).config.system.build.manual.optionsJSON;
          darwin-options-json = (inputs.nix-darwin.lib.darwinSystem { modules = [ { nixpkgs.pkgs = pkgs; } ]; }).config.system.build.manual.optionsJSON;
          # VMs
          playground-vm = self.nixosConfigurations.playground.config.system.build.startVm;
          toolbox-vm = self.nixosConfigurations.toolbox.config.system.build.startVm;
          docker-vm = self.nixosConfigurations.docker.config.system.build.startVm;
          toolbox-ui-vm = self.nixosConfigurations.toolbox-ui.config.system.build.startVm;
          gnome-vm = self.nixosConfigurations.gnome.config.system.build.startVm;
          firefox-vm = self.nixosConfigurations.firefox.config.system.build.startVm;
          k3s-vm = self.nixosConfigurations.k3s.config.system.build.startVm;
          # QCOW2 images
          playground-qcow2 = import "${nixpkgs}/nixos/lib/make-disk-image.nix" {
            inherit lib;
            config = self.nixosConfigurations.playground-qcow2.config;
            pkgs = pkgsLinux;
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
          # Docker images
          playground-docker = (utils.mkDocker { name = "playground"; targetSystem = "aarch64-linux"; }).config.system.build.tarball;
          # Packages
          macos = {
            socket_vmnet = (utils.callPkg ./pkgs/darwin/applications/virtualization/socket_vmnet.nix);
            angle = (utils.callPkg ./pkgs/darwin/development/libraries/angle.nix);
            libepoxy = (utils.callPkg ./pkgs/darwin/development/libraries/libepoxy.nix);
            virglrenderer = (utils.callPkg ./pkgs/darwin/development/libraries/virglrenderer.nix);
            qemu = (utils.callPkg ./pkgs/darwin/applications/virtualization/qemu.nix);
          };
        };
        aarch64-linux = {
          k3s-bin = (pkgsLinux.callPackage ./pkgs/nixos/networking/cluster/k3s-bin.nix { inherit sources; });
        };
      };

      darwinModules = {
        fonts = import ./modules/darwin/fonts.nix;
        hunspell = import ./modules/darwin/hunspell.nix;
        nix = import ./modules/darwin/nix.nix;
        socket-vmnet = import ./modules/darwin/socket-vmnet.nix;
        tuptime = import ./modules/darwin/tuptime.nix;
      };

      homeManagerModules = {
        alacritty = import ./modules/home-manager/alacritty.nix;
        emacs = import ./modules/home-manager/emacs.nix;
        kitty = import ./modules/home-manager/kitty.nix;
        tmux = import ./modules/home-manager/tmux.nix;
      };

      nixosModules = {
        minimize = import ./modules/nixos/minimize.nix;
        nix = import ./modules/nixos/nix.nix;
        qemu-guest = import ./modules/nixos/qemu-guest.nix;
        kiosk = import ./modules/nixos/kiosk.nix;
      };

      overlays = {
        nixos-option = import ./overlays/tools/nix/nixos-option.nix;
        emacs = import ./overlays/applications/editors/emacs.nix;
        helm = import ./overlays/applications/networking/cluster/helm.nix;
        lib = self: super: {
          lib = utils.extendLib super.lib;
        };
      };
    };
}
