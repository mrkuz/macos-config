{
  inputs = {
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    # nixpkgs-darwin.url = "github:nixos/nixpkgs/nixpkgs-24.05-darwin";
    # nixpkgs-master.url = "github:nixos/nixpkgs/master";
    nixos-stable.url = "github:nixos/nixpkgs/nixos-25.05";
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
    apple-fonts = {
      url = "github:Lyndeno/apple-fonts.nix";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
  };

  outputs =
    { self, ... }@inputs:
    let
      sources = import ./nix/sources.nix;
      nixpkgs = inputs.nixpkgs-unstable;
      lib = utils.extendLib nixpkgs.lib;
      pkgs = utils.mkPkgs { };
      pkgsLinux = utils.mkPkgs { system = "aarch64-linux"; };

      vars = {
        currentSystem = "aarch64-darwin";
        primaryUser = "markus";
        sshKeyFile = ./users/darwin/markus/files/id_ed25519.pub;
      };

      versions = {
        darwin.stateVersion = 6;
        homeManager.stateVersion = "26.05";
        nixos.stateVersion = "26.05";
        nixos.stableVersion = "25.11";
        rev = self.rev or self.dirtyRev or "dirty";
      };

      utils = {
        attrsToValues = attrs: lib.attrsets.mapAttrsToList (name: value: value) attrs;

        extendLib =
          lib:
          lib.extend (
            self: super: {
              hm = inputs.home-manager.lib.hm;
              vmHostAttrs =
                options: block: if (builtins.hasAttr "cores" options.virtualisation) then block else { };
              buildQemuVm =
                {
                  name,
                  targetSystem,
                  configuration,
                }:
                (utils.mkVm { inherit name targetSystem configuration; }).config.system.build.startVm;
            }
          );

        mkPkgs =
          {
            system ? vars.currentSystem,
            nixpkgs ? inputs.nixpkgs-unstable,
          }:
          import nixpkgs {
            inherit system;
            config.allowUnfree = true;
            overlays = [
              inputs.emacs-overlay.overlay
              inputs.apple-silicon.overlays.apple-silicon-overlay
              (_: super: self.packages."${system}")
            ]
            ++ utils.attrsToValues self.overlays;
          };

        callPkg = package: pkgs.callPackage package { inherit sources; };

        mkHomeManagerModule =
          {
            name,
            version ? versions.homeManager.stateVersion,
          }:
          {
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
              ]
              ++ utils.attrsToValues self.homeManagerModules;
            };
          };

        mkVm =
          {
            name,
            targetSystem ? vars.currentSystem,
            selfReference ? self,
            nixpkgs ? inputs.nixpkgs-unstable,
            hostPkgs ? pkgs,
            profile ? ./profiles/nixos/qemu-vm.nix,
            configuration ? {
              imports = [ (./vms/nixos + "/${name}.nix") ];
            },
          }:
          lib.nixosSystem {
            specialArgs = {
              inherit vars versions nixpkgs;
              self = selfReference;
              systemName = name;
              pkgsStable = utils.mkPkgs {
                system = targetSystem;
                nixpkgs = inputs.nixos-stable;
              };
            };
            modules = [
              profile
              (
                { lib, options, ... }:
                {
                  networking.hostName = lib.mkDefault name;
                  nixpkgs.pkgs = utils.mkPkgs {
                    system = targetSystem;
                    inherit nixpkgs;
                  };
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
                }
              )
              inputs.home-manager.nixosModules.home-manager
              (utils.mkHomeManagerModule { inherit name; })
              configuration
            ]
            ++ utils.attrsToValues self.nixosModules;
          };

        mkDocker =
          {
            name,
            targetSystem ? vars.currentSystem,
            selfReference ? self,
            configuration ? {
              imports = [ (./vms/nixos + "/${name}.nix") ];
            },
          }:
          lib.nixosSystem {
            specialArgs = {
              inherit vars versions nixpkgs;
              self = selfReference;
              systemName = name;
              pkgsStable = utils.mkPkgs {
                system = targetSystem;
                nixpkgs = inputs.nixos-stable;
              };
            };
            modules = [
              ./profiles/nixos/docker-tar.nix
              (
                { lib, options, ... }:
                {
                  networking.hostName = lib.mkDefault name;
                  nixpkgs.pkgs = (utils.mkPkgs { system = targetSystem; });

                  system = {
                    inherit name;
                    stateVersion = versions.nixos.stateVersion;
                    configurationRevision = versions.rev;
                  };
                }
              )
              inputs.home-manager.nixosModules.home-manager
              (utils.mkHomeManagerModule { inherit name; })
              configuration
            ]
            ++ utils.attrsToValues self.nixosModules;
          };

        mkDarwin =
          { name }:
          inputs.nix-darwin.lib.darwinSystem {
            specialArgs = {
              inherit
                self
                vars
                versions
                nixpkgs
                ;
              systemName = name;
              # pkgsStable = utils.mkPkgs { nixpkgs = inputs.nixos-stable; };
            };
            modules = [
              { nixpkgs.pkgs = pkgs; }
              inputs.home-manager.darwinModules.home-manager
              (utils.mkHomeManagerModule { inherit name; })
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
            ]
            ++ utils.attrsToValues self.darwinModules;
          };
      };
    in
    {
      inherit utils;

      nixosConfigurations.playground = utils.mkVm {
        name = "playground";
        targetSystem = "aarch64-linux";
      };
      nixosConfigurations.playground-ui = utils.mkVm {
        name = "playground-ui";
        targetSystem = "aarch64-linux";
      };
      nixosConfigurations.docker = utils.mkVm {
        name = "docker";
        targetSystem = "aarch64-linux";
      };
      nixosConfigurations.gnome = utils.mkVm {
        name = "gnome";
        targetSystem = "aarch64-linux";
      };
      nixosConfigurations.firefox = utils.mkVm {
        name = "firefox";
        targetSystem = "aarch64-linux";
      };
      nixosConfigurations.k3s = utils.mkVm {
        name = "k3s";
        targetSystem = "aarch64-linux";
      };

      darwinConfigurations."bootstrap" = utils.mkDarwin { name = "bootstrap"; };
      darwinConfigurations."m4" = utils.mkDarwin { name = "m4"; };

      packages = {
        aarch64-darwin = {
          # options.json
          home-manager-options-json = inputs.home-manager.packages.aarch64-darwin.docs-json;
          nixos-options-json =
            (lib.nixosSystem { modules = [ { nixpkgs.pkgs = pkgs; } ]; })
            .config.system.build.manual.optionsJSON;
          darwin-options-json =
            (inputs.nix-darwin.lib.darwinSystem { modules = [ { nixpkgs.pkgs = pkgs; } ]; })
            .config.system.build.manual.optionsJSON;
          # VMs
          playground-vm = self.nixosConfigurations.playground.config.system.build.startVm;
          playground-ui-vm = self.nixosConfigurations.playground-ui.config.system.build.startVm;
          docker-vm = self.nixosConfigurations.docker.config.system.build.startVm;
          gnome-vm = self.nixosConfigurations.gnome.config.system.build.startVm;
          firefox-vm = self.nixosConfigurations.firefox.config.system.build.startVm;
          k3s-vm = self.nixosConfigurations.k3s.config.system.build.startVm;
          # Docker images
          playground-docker =
            (utils.mkDocker {
              name = "playground";
              targetSystem = "aarch64-linux";
            }).config.system.build.tarball;
          # Packages
          macos = {
            socket_vmnet = (utils.callPkg ./pkgs/darwin/applications/virtualization/socket_vmnet.nix);
            angle = (utils.callPkg ./pkgs/darwin/development/libraries/angle.nix);
            libepoxy = (utils.callPkg ./pkgs/darwin/development/libraries/libepoxy.nix);
            virglrenderer = (utils.callPkg ./pkgs/darwin/development/libraries/virglrenderer.nix);
            qemu = (utils.callPkg ./pkgs/darwin/applications/virtualization/qemu.nix);
            waypipe = (utils.callPkg ./pkgs/darwin/by-name/wa/waypipe-darwin.nix);
            cocoa-way = (utils.callPkg ./pkgs/darwin/by-name/co/cocoa-way.nix);
          };
          # Fonts
          sf-mono = inputs.apple-fonts.packages.${pkgs.system}.sf-mono;
          sf-mono-nerd = inputs.apple-fonts.packages.${pkgs.system}.sf-mono-nerd;
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
      };

      homeManagerModules = {
        alacritty = import ./modules/home-manager/alacritty.nix;
        emacs = import ./modules/home-manager/emacs.nix;
        fish = import ./modules/home-manager/fish.nix;
        tmux = import ./modules/home-manager/tmux.nix;
        zsh = import ./modules/home-manager/zsh.nix;
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
        lib = self: super: {
          lib = utils.extendLib super.lib;
        };
      };
    };
}
