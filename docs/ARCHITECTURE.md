# Architecture Overview

## Purpose
This repository defines reproducible system and user environments via Nix flakes for macOS (nix-darwin) and NixOS, with Home Manager for per-user configuration and SOPS for secret management.

## Top-Level
- `flake.nix`: Inputs, systems map, and flake outputs.
  - Declares inputs: `nixpkgs`, `home-manager`, `nix-darwin`, `nix-homebrew`, `flake-utils`, `disko`, `sops-nix`, `wezterm`, `lunar-tools`.
  - Defines two system maps:
    - Darwin `lunar`: `aarch64-darwin`, user `kisw`, overlays enabled, Homebrew enabled.
    - NixOS `home-desktop`: `x86_64-linux`, user `kirksw`.
  - Outputs:
    - `apps`: convenience commands (`build`, `switch`, `rollback`).
    - `darwinConfigurations`: built by `lib/darwin.nix`.
    - `nixosConfigurations`: built by `lib/nixos.nix`.
- `flake.lock`: Pinned inputs for reproducibility.
- `README.md`: Quickstart and TODOs.

## Libraries (`lib/`)
Reusable builders that wire inputs and host/home modules:
- `lib/default.nix`: Aggregates helpers `homemanager`, `darwin`, `nixos`, `app`.
- `lib/darwin.nix`:
  - `mkDarwinSystem hostname config`: wraps `darwin.lib.darwinSystem`.
  - Injects overlays, `sops-nix`, `home-manager`; plugs host module and generated HM module.
  - Optionally enables `nix-homebrew` when `config.enableHomebrew` is true.
- `lib/nixos.nix`:
  - `mkNixosSystem hostname config`: wraps `nixpkgs.lib.nixosSystem`.
  - Adds `disko`, overlays, `sops-nix` (note: currently imports darwin module; likely should be `sops-nix.nixosModules.sops`), and `home-manager`.
- `lib/homemanager.nix`:
  - `mkHomeManagerModule config`: returns a nix-darwin/NixOS module configuring Home Manager:
    - `users.${config.user} = import config.homeModule`.
    - `sharedModules = [ inputs.sops-nix.homeManagerModules.sops ../modules/home ]`.
    - `extraSpecialArgs = { inputs self; } // config`.
- `lib/app.nix`: helpers for `apps/*` (referenced in flake outputs).

## Modules (`modules/`)
- `modules/darwin`:
  - `default.nix`: auto-imports all submodules; sets `module.baseline.enable = true` in `modules/home/default.nix` (for HM side).
  - Example services: `aerospace.nix`, `jankyborders.nix`, `tailscale.nix`; Homebrew config in `programs/homebrew.nix`, casks/formulae in `casks.nix` and `brews.nix`.
- `modules/home`:
  - `default.nix`: auto-imports all submodules; enables `module.baseline.enable = true`.
  - Program modules: `zsh.nix`, `neovim.nix`, `tmux.nix`, `wezterm.nix`, `ghostty.nix`, `colima.nix`, `developer.nix`, `devops.nix`, `youtube.nix`, `zellij.nix`, etc.
  - Service modules: `homerow.nix` (disabled in `hosts/darwin/work/home.nix` by default), `sops.nix`.
- `modules/nixos`:
  - `default.nix`: auto-imports all submodules.
  - `template.nix`: scaffold for new NixOS modules.
- `modules/shared`:
  - Shared, cross-platform declarations and overlays wiring via `overlays.nix`.

## Hosts (`hosts/`)
- macOS: `hosts/darwin/work/default.nix`
  - Imports `modules/shared` and `modules/darwin`.
  - Enables `aerospace`, `tailscale`, `jankyborders`.
  - Configures nix settings, TouchID sudo, macOS defaults (Dock, Finder, keyboard), and sets system/user shells.
- macOS Home Manager: `hosts/darwin/work/home.nix`
  - Enables core HM modules: `sops`, `zsh`, `neovim`, `developer`, `tmux`, `colima`, `devops`, `youtube`, `zellij`, `lunar`, `ghostty`, `wezterm`, `qemu`.
- NixOS: `hosts/nixos/desktop/default.nix`
  - Imports `modules/shared`.
  - Configures boot, X11 (lightdm + bspwm), picom compositor, docker, users, etc.
- NixOS Home Manager: `hosts/nixos/desktop/home.nix`
  - Sets up theme, services (polybar, dunst), and HM home basics.

## Overlays (`overlays/`)
- Custom overlays live here; auto-wired via `modules/shared/overlays.nix` or directly in host configs. Current examples: `colima`, `kube-slice`, `amp-cli` (backup file), plus a short README.

## Apps (`apps/*/*`)
- Simple helper scripts for build/switch/rollback per platform. macOS aarch64 scripts are implemented; Linux placeholders exist.

## Secrets (`secrets/`)
- SOPS-managed secrets, grouped by domain: `git/`, `ssh/`, `k8s/`. Accessed via `sops-nix` modules; no plaintext secrets should be introduced elsewhere.

## Configuration Flow
1. `flake.nix` picks host entry from `darwinSystems` or `nixosSystems`.
2. The corresponding `mk*System` function in `lib/` composes:
   - Core modules (`sops-nix`, `home-manager`, platform modules, overlays).
   - Host module (`hosts/.../default.nix`) and generated HM module from `lib/homemanager.nix` that points to `hosts/.../home.nix`.
3. `modules/*/default.nix` auto-imports all submodules for that platform.
4. `apps/aarch64-darwin/switch` (or flake command) builds and activates the system.

## Notable Conventions
- Auto-import pattern: recursively import all `.nix` modules except `default.nix` and `template.nix`.
- Use `sharedModules` in Home Manager to apply common HM modules across hosts.
- Overlays: prefer localized `overlays/` definitions and pin via flake inputs or shared overlay module.

## Known Gaps / Follow-ups
- `lib/nixos.nix` uses `sops-nix.darwinModules.sops` for NixOS; should likely be `sops-nix.nixosModules.sops`.
- `hosts/nixos/desktop/home.nix` references paths under `modules/nixos/config/...`; verify file paths (`moudles` typo in `polybar-bars`).
- Linux build scripts under `apps/*-linux` are placeholders; consider implementing or remove in favor of flake apps only.

## Typical Workflows
- macOS build:
  ```bash
  apps/aarch64-darwin/build
  ./result/sw/bin/darwin-rebuild switch --flake .#
  ```
- macOS switch:
  ```bash
  apps/aarch64-darwin/switch
  ```
- Rollback:
  ```bash
  apps/aarch64-darwin/rollback
  ```
- NixOS build (manual):
  ```bash
  nix --extra-experimental-features 'nix-command flakes' build .#nixosConfigurations.home-desktop.config.system.build.toplevel
  ```
