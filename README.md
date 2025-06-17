# NixFiles v2.0

## Overview

This is a nix configuration primarily for macOS, but it can also be used on Linux.

## TODO

- [ ] add overlay example (neovim-nightly)
- [ ] reimplement darwin dock setup
- [ ] correctly setup config for nixos host

## Getting started

- Install nix `curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install --determinate`
- Clone this repo `cd ~ && git clone git@github.com:kirksw/nixfiles-v2.git`
- Update username in `flake.nix` and `home-manager` config
- Mac: `darwin-rebuild switch --flake ~/nixfiles-v2#aarch64-darwin`
- Linux: `nixos-rebuild switch --flake ~/nixfiles-v2#x86_64-linux`

## Daily operations

Make sure you commit and push everything after a successful change, this ensures that you can restore to this configuration by checking out that commit.

There are a couple of aliases to make your life easier:

- Nix switch: `ns` - this will switch the system configuration to the new changes
- Nix update: `nu` - this will update the nix channels

If you want to add a package you can simply add it to the flake, and run `ns` to apply it.

If you want to update the versions of packages, you can run `nu` to update the nix channels, and then run `ns` to apply the changes.

## Don't like this?

- uninstall `/nix/nix-installer uninstall`

## References

### inspirations

- [gh:dustinlyons/nisox-config](https://github.com/dustinlyons/nixos-config)

### documentation

- [gh:nixpkgs](https://github.com/NixOS/nixpkgs)
- [gh:home-manager](https://github.com/nix-community/home-manager/tree/master/modules/programs)
- [gh:nix-darwin](https://github.com/LnL7/nix-darwin)
