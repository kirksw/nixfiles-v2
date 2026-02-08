# Repository Guidelines

## Project Structure & Module Organization
This is a Nix flake-based mono-repo for macOS (`nix-darwin`) and Linux (`NixOS`) systems.

- `flake.nix`: entry point (inputs, systems, apps, checks).
- `hosts/`: host-level configs (`hosts/darwin/work`, `hosts/nixos/*`).
- `modules/`: reusable modules (`darwin/`, `home/`, `nixos/`, `shared/`).
- `config/`: dotfiles and program configs linked by modules.
- `packages/`: custom packages (`packages/*/default.nix` auto-discovered).
- `overlays/`: package overlays.
- `apps/<system>/`: operational wrappers (`build`, `switch`, `rollback`).
- `secrets/`: SOPS-encrypted YAML secrets.
- `docs/agents/`: agent playbooks and repo-specific AI workflow notes.

## Build, Test, and Development Commands
- `apps/aarch64-darwin/build`: build macOS generation without switching.
- `apps/aarch64-darwin/switch`: build and apply macOS config.
- `apps/aarch64-darwin/rollback`: rollback to a previous macOS generation.
- `apps/x86_64-linux/switch <host>`: apply Linux host config (example: `apps/x86_64-linux/switch nixos-ry6a`).
- `nix flake check`: run flake checks (including deploy checks).
- `nix flake update [input]`: update lockfile inputs.
- `nix run .#update-packages`: run package update scripts for entries in `packages/`.

## Coding Style & Naming Conventions
- Nix files use 2-space indentation and trailing commas in attribute sets/lists.
- Prefer small, composable modules; follow templates in `modules/*/template.nix`.
- Name modules and files by feature (`modules/home/programs/<tool>.nix`).
- Keep host names and system keys explicit (`lunar`, `nixos-ry6a`).
- Use format/lint tools available in the environment (`nixfmt`, `statix`) before opening PRs.

## Testing Guidelines
- No global unit test suite is enforced; validation is build-oriented.
- Minimum check for config changes: `nix flake check` and target system build (`apps/aarch64-darwin/build` or Linux switch/build path).
- For package changes, also run: `nix build .#<package-name>`.

## Commit & Pull Request Guidelines
- Commit style in history is concise, imperative, and lowercase (for example: `add opencode`, `fixes around k3 nodes`).
- Conventional-style prefixes are acceptable when useful (for example: `chore(flake): update flake.lock`).
- PRs should include:
  - What changed and why.
  - Target host(s)/module(s) affected.
  - Commands run to validate (for example: `nix flake check`, `apps/aarch64-darwin/build`).
  - Screenshots only for UI-facing config changes.

## Security & Configuration Tips
- Never commit plaintext secrets; keep secrets under `secrets/` and edit with `sops`.
- Validate `.sops.yaml` rules when adding new secret files.
