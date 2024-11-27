# NixFiles v2.0

## Overview

I wanted better handling of both mac and nix clients, as the initial config was target intitally to nixos and was extended to mac over time.

## TODO

- [ ] reimplement darwin dock setup

## Getting started

- install nix
- clone this repo
- mac: `darwin-rebuild switch --flake ~/nixfiles-v2#aarch64-darwin`
- nixos: `nixos-rebuild switch --flake ~/nixfiles-v2#x86_64-linux`

## Adding packages



## References

### inspirations

- [gh:dustinlyons/nisox-config](https://github.com/dustinlyons/nixos-config)

### documentation

- [gh:nixpkgs](https://github.com/NixOS/nixpkgs)
- [gh:home-manager](https://github.com/nix-community/home-manager/tree/master/modules/programs)
- [gh:nix-darwin](https://github.com/LnL7/nix-darwin)
