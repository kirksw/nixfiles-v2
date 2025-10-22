# Agent Session Notes (2025-10-22)

## Goals
- Produce an architecture overview for the repository
- Seed actionable TODOs for future improvements

## Findings
- Flake composes both nix-darwin and NixOS systems with Home Manager and SOPS.
- macOS `lunar` host is primary; NixOS `home-desktop` is secondary.
- Auto-import patterns in `modules/*/default.nix` keep module wiring simple.
- Overlays present; Linux app scripts are placeholders.

## Risks / Gaps Observed
- `lib/nixos.nix` references `sops-nix.darwinModules.sops` for NixOS — likely incorrect.
- `hosts/nixos/desktop/home.nix` has path typos (`moudles` vs `modules`) and polybar path inconsistencies.
- `apps/*-linux` scripts are placeholders; could mislead contributors.

## Next Steps
- Fix SOPS module for NixOS and path typos.
- Add a minimal NixOS build/switch doc to README.
- Optionally implement Linux `apps/*/switch` or remove them.
