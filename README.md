# Introduction

> ✅ Works on my machine

Welcome to my declarative, modular and - of course - opinionated MacOS system configuration using [nix-darwin](https://github.com/LnL7/nix-darwin) with [flakes](https://nix.dev/concepts/flakes.html). Please be aware this might not work out of the box for you.

Features:

- Install and configure software packages via [nix](https://nix.dev)
- Build and run [NixOS](https://nixos.org) virtual machines using [QEMU](https://www.qemu.org) (see [here](#build-and-run-vms))
- Manage [Homebrew](https://brew.sh) installations via [nix-homebrew](https://github.com/zhaofengli/nix-homebrew)
- Use [Home Manager](https://github.com/nix-community/home-manager) instead of plain dotfiles

Notes:

- I don't use nix-darwin for system settings (yet?)
- Not everything is installed via nix. I use following guideline:
    1. If it is offical Apple software or there are no other options -> App Store (using [mas](https://github.com/mas-cli/mas))
    2. If it is proprietary software or distributed as DMG -> [Homebrew](https://brew.sh)
    3. Else -> nix
    4. Exception: Some tools for development -> [mise](https://mise.jdx.dev)
- [Homebrew Bundle](https://github.com/Homebrew/homebrew-bundle) keeps track of software installed via App Store or Homebrew
- Not handled by Home Manger:
    - [Emacs](https://www.gnu.org/software/emacs/) configuration (see [here](https://github.com/mrkuz/emacs.d))
    -  ... and my [Hammerspoon](https://www.hammerspoon.org) configuration (see [here](https://github.com/mrkuz/hammerspoon))

# Installation

1. Install Nix

```shell
sh <(curl -L https://nixos.org/nix/install)
```

2. Clone repo

```shell
nix shell --extra-experimental-features 'nix-command flakes' nixpkgs#git
git clone https://github.com/mrkuz/macos-config
```

3. Install nix-darwin

```shell
nix run --extra-experimental-features 'nix-command flakes' nix-darwin -- switch --flake .
darwin-rebuild switch --flake .
```

# Let's go

`go.sh` provides a bunch of commands to simplify recurring system maintenance tasks.

## ./go.sh update

Updates flake inputs and brew formulae. Shows outdated brew and App Store packages.

## ./go.sh upgrade

Runs `darwin-rebuild` and upgrades outdated brew and App Store packages. Updates the Brewfile.

## ./go.sh clean

Deletes old generations, runs garbage collection, removes unused brew dependencies and prunes the brew cache.

<a id="build-and-run-vms"></a>

# Build and run NixOS VMs

To build Linux packages on MacOS, you need a [remote Linux builder](https://nixos.org/manual/nixpkgs/stable/#sec-darwin-builder). Thankfully this can be archived with one line in nix-darwin:

```nix
nix.linux-builder.enable = true;
```

Usually the builder starts automatically. If you dislike this, add following:

```nix
launchd.daemons.linux-builder.serviceConfig = {
  KeepAlive = lib.mkForce false;
  RunAtLoad = lib.mkForce false;
};
```

You then need to start the builder manually:

```shell
sudo launchctl start org.nixos.linux-builder
```

See host configuration '[m3](hosts/darwin/m3.nix)' for a full example.

After the builder is up and running, you can launch every VM defined in `hosts/nixos/vm/` with a single command:

```shell
nix run .#playground-vm
```

In case you run into [issues](https://github.com/NixOS/nix/issues/4119) with [sandboxed](https://nixos.org/manual/nix/stable/command-ref/conf-file.html#conf-sandbox) builds, you can disable the sandbox temporary with `--option sandbox false`.

Use cases: Run docker, isolate applications, ... see [hosts](#hosts) section.

To learn how to add additional VMs, check out [flake.nix](flake.nix) (look for `mkVm`).

VMs can also be build out-of-tree, see this [example](examples/darwin/nixos-vm).

The QEMU package provided and used by this configuration comes with support for hardware accelerated graphics, based on the awesome work of [Akihiko Odaki](https://gist.github.com/akihikodaki/87df4149e7ca87f18dc56807ec5a1bc5).

The '[qemuGuest](#qemu-guest)' module provides a bunch of useful configuration options for QEMU guests.

# Building blocks

<a id="hosts"></a>

## Hosts

Host expressions represent a physical of virtual machine. Kind of what you would put in `darwin-configuration.nix` or `configuration.nix`.

| Name       | System              | Description                                                                        |
|------------|---------------------|------------------------------------------------------------------------------------|
| m3         | darwin              | Configuration for my Mac Mini M1                                                   |
| docker     | nixos (vm, console) | Runs [Docker Engine](https://docs.docker.com/engine/)                              |
| firefox    | nixos (vm, graphic) | Runs [Firefox Developer Edition](https://www.mozilla.org/en-US/firefox/developer/) |
| gnome      | nixos (vm, graphic) | Latest [GNOME desktop environment](https://www.gnome.org) (without apps)           |
| k3s        | nixos (vm, console) | Runs [k3s](https://k3s.io)                                                         |
| playground | nixos (vm, console) | NixOS playground to fiddle around                                                  |
| toolbox    | nixos (vm, console) | VM with some CLI tools preconfigured                                               |
| toolbox-ui | nixos (vm, graphic) | VM with some GUI tools preconfigured                                               |

<a id="users"></a>

## Users

Home Manager configuration per user. Usually imported by one ore more [hosts](#hosts) (e.g. '[m3](hosts/darwin/m3.nix)' host).

| Name   | Description     |
|--------|-----------------|
| markus | Yeah, that's me |

## Modules

Modules are used to implement specific features. They can declare options for customization. Learn more about modules in the [NixOS manual](https://nixos.org/manual/nixos/stable/index.html#sec-writing-modules).

I use following conventions:

1. Module options are exposed under `modules.NAME`
2. Each module has to be enabled explicitly: `modules.NAME.enable = true;`

Check out any [host](hosts) or [user](users) expression for example usage.

| Name         | System        | Description                                                                                                        |
|--------------|---------------|--------------------------------------------------------------------------------------------------------------------|
| nix          | darwin, nixos | Configures nix, [flake registries](https://nixos.org/manual/nix/stable/command-ref/new-cli/nix3-registry) and more |
| fonts        | darwin        | Adds a bunch of fonts                                                                                              |
| hunspell     | darwin        | Adds [Hunspell](http://hunspell.github.io) spell checker and a couple of dictionaries                              |
| socket-vmnet | darwin        | Adds and configures [socket_vmnet](https://github.com/lima-vm/socket_vmnet)                                        |
| tuptime      | darwin        | Configures [tuptime](https://github.com/rfmoz/tuptime) to keep track of system uptime                              |
| emacs        | home-manager  | Adds [Emacs](https://www.gnu.org/software/emacs/) including some dependencies and runs daemon at log in            |
| kitty        | home-manager  | Adds and configures [kitty](https://sw.kovidgoyal.net/kitty/) terminal emulator                                    |
| tmux         | home-manager  | Adds and configure [tmux](https://github.com/tmux/tmux/wiki) terminal multiplexer                                  |
| kiosk        | nixos         | Runs a single application in fullscreen mode                                                                       |
| minimize     | nixos         | Minimized variant of NixOS (only recommmended for non-interactive systems)                                         |
| qemu-guest   | nixos         | Provides convenience features for QEMU guests                                                                      |

### nix

Takes care of configuring [nix](https://nixos.org/manual/nix/stable/command-ref/conf-file) and adds some nix-related packages.

Also:

- Creates a link to the revision of this configuration used for building -> `/etc/nix/current/`
- Creates a link of the nixpkgs used for building -> `/etc/nix/nixpkgs`
- Adds nixpkgs used for building as `nixpkgs` to the flake registry
- Adds `nixpkgs-unstable`, `nixos-stable` and `nixos-unstable` to the flake registry

*NixOS-specific*

- Creates a compatibility layer in `/etc/nixos/compat` which can be used with tools that do not support flakes (e.g. nixos-option). Powered by [flake-compat](https://github.com/edolstra/flake-compat).

### socket-vmnet

Adds [socket_vmnet](https://github.com/lima-vm/socket_vmnet) and a corresponding launch daemon.

*Options*

| Name    | Description               | Default         |
|---------|---------------------------|-----------------|
| gateway | Gateway IP used for vmnet | 192.168.105.1   |
| dhcpEnd | End of DHCP range         | 192.168.105.100 |

### kiosk

Runs a single application in fullscreen mode.

*Options*

| Name    | Description                                                             | Default | Example                       |
|---------|-------------------------------------------------------------------------|---------|-------------------------------|
| wayland | Use wayland ([cage](https://github.com/cage-kiosk/cage)) instead of X11 | false   |                               |
| program | Path to application to run (required)                                   | -       | `${pkgs.firefox}/bin/firefox` |
| user    | Run as this user (required)                                             | -       |                               |


### minimize

Creates a minimized variant of NixOS.

*Options*

| Name    | Description                               | Default | Example |
|---------|-------------------------------------------|---------|---------|
| noLogin | Disable console login                     | false   |         |
| noNix   | Remove nix package and disable daemon     | false   |         |

<a id="qemu-guest"></a>

### qemu-guest

Provides convenience features for QEMU guests.

Also check out the existing NixOS options (`virtualisation.*`) for customisation.

*Options*

| Name        | Description                                                                 | Default |
|-------------|-----------------------------------------------------------------------------|---------|
| graphics    | Run QEMU with graphics window                                               | false   |
| opengl      | Enable hardware accelerated graphics                                        | false   |
| user        | Create user                                                                 | -       |
| autoLogin   | Auto-login user                                                             | false   |
| dhcp        | Use DHCP for network configuration                                          | false   |
| sshd        | Configure and start SSH server                                              | false   |
| vmnet       | Use [vmnet](https://developer.apple.com/documentation/vmnet) for networking | false   |
| socketVmnet | Use [socket_vmnet](https://github.com/lima-vm/socket_vmnet) for networking  | false   |
| skipLogin   | Skip login on serial console                                             | false   |

## Profiles

Technically profiles are also modules. But they are intended to be used in [flake.nix](flake.nix) and thus cannot be enabled in hosts or user expressions.

| Name       | Description                            |
|------------|----------------------------------------|
| docker-tar | Used to create Docker image (tar)      |
| qemu-qcow2 | Used to create NixOS QCOW2 disk images |
| qemu-vm    | Used to create NixOS QEMU VMs          |

<a id="qemu-vm"></a>

### qemu-vm

This profile adds the `config.system.build.startVm` derivation, which produces a script `start-NAME-vm`. The script launches QEMU with comand line arguments based on the configuration (`virtualisation.*` options and the '[qemuGuest](#qemu-guest)' module).

## Packages

Collection of additional (or patched) software packages.

[niv](https://github.com/nmattia/niv) is used to keep track of package sources.

| Name                                                    | System | Description                                                                                                                                  |
|---------------------------------------------------------|--------|----------------------------------------------------------------------------------------------------------------------------------------------|
| [qemu](https://www.qemu.org)                            | darwin | QEMU with patches from [Akihiko Odaki](https://gist.github.com/akihikodaki/87df4149e7ca87f18dc56807ec5a1bc5), to enable accelerated graphics |
| [socket_vmnet](https://github.com/lima-vm/socket_vmnet) | darwin | Allows QEMU to use [vmnet](https://developer.apple.com/documentation/vmnet) without root privileges                                          |
| [angle](https://github.com/google/angle)                | darwin | OpenGL ES implementation which provides translation to Apple's [Metal](https://developer.apple.com/metal/)                                   |
| [libepoxy](https://github.com/anholt/libepoxy)          | darwin | Library for OpenGL pointer management (with patches from Akihiko Odaki)                                                                      |
| [virglrenderer](https://docs.mesa3d.org/drivers/virgl/) | darwin | Virtual GPU for QEMU providing 3D acceleration (with patches from Akihiko Odaki)                                                             |
| [k3s-bin](https://k3s.io/)                              | nixos  | Single-binary Kubernetes distribution (release binary)                                                                                       |

## Overlays

Overlays are used to extend or modify [nixpkgs](https://github.com/NixOS/nixpkgs). Learn more in the [NixOS manual](https://nixos.org/manual/nixpkgs/stable/#sec-overlays-definition).

| Name         | System | Description                                                                               |
|--------------|--------|-------------------------------------------------------------------------------------------|
| nixos-option | nixos  | Wraps nixos-option to work with flake-based systems (requires `module.nix.enable = true`) |
