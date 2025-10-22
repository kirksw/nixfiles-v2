## Agents Guide for this Repo

This document gives AI coding agents (and humans) clear, safe, and efficient ways to work in this repository.

### Scope and Goals
- **Goal**: Maintain macOS (nix-darwin) and NixOS configurations via Nix flakes.
- **Agents should**: Make minimal, high-quality edits; keep builds reproducible; avoid leaking secrets.

### Repo Overview (what matters to agents)
- **Entry points**:
  - `flake.nix`: inputs, systems, and flake outputs.
  - `lib/`: helper functions used by flake outputs.
  - `hosts/`: host-level system and home-manager modules.
  - `modules/`: reusable Nix modules (darwin/home/nixos/shared).
  - `overlays/`: custom package overlays.
  - `secrets/`: SOPS-managed secrets (do not commit plaintext secrets elsewhere).
  - `apps/*/*`: convenience scripts for build/switch/rollback.
- **Darwin config (active)**: `darwinConfigurations.aarch64-darwin` with user `kisw` and Homebrew enabled.
- **NixOS config**: `nixosConfigurations.home-desktop` (x86_64-linux).

### Common Workflows
- **macOS (aarch64-darwin)**
  - Local scripts (simple, opinionated):
    - Build only:
      ```bash
      apps/aarch64-darwin/build
      ```
    - Switch (build + activate):
      ```bash
      apps/aarch64-darwin/switch
      ```
    - Roll back to a prior generation (interactive):
      ```bash
      apps/aarch64-darwin/rollback
      ```
  - Equivalent flake commands (manual):
    ```bash
    nix --extra-experimental-features 'nix-command flakes' build .#darwinConfigurations.aarch64-darwin.system
    ./result/sw/bin/darwin-rebuild switch --flake .#
    ```
- **Linux scripts**
  - `apps/aarch64-linux/switch` and `apps/x86_64-linux/switch` are placeholders (not implemented yet). Prefer flake commands for NixOS builds.

### Agent Editing Rules
- **Plan before edits**: Identify target files and minimal change set.
- **Read, then edit**: Open files before modifying; limit scope; keep unrelated code unchanged.
- **Follow style**: Prefer clear names, guard clauses, minimal nesting; avoid unnecessary try/catch; write concise, purposeful comments only when non-obvious.
- **Small, cohesive edits**: Group related changes; avoid wide refactors unless requested.
- **No plaintext secrets**: Use `secrets/` with SOPS-Nix; never commit tokens or credentials.

### Secrets and SOPS-Nix
- Secrets live under `secrets/` and are referenced via sops-nix. If adding a secret:
  1. Create/extend an encrypted file in `secrets/.../*.yaml` (SOPS-managed).
  2. Reference it from appropriate module(s) with sops-nix options.
  3. Do not output or log decrypted values.

### Commit and PR Guidance
- **Commits**
  - One logical change per commit; focus on the “why”.
  - Message example:
    ```
    darwin(homebrew): enable additional developer tools to support Go projects
    ```
- **Pull Requests**
  - Keep titles clear and scoped.
  - Include: summary of changes, rationale, and simple test plan (e.g., build + switch succeeded).

### Documentation Rules
- **Agent docs location**: Place any agent-authored documentation under `docs/agents/YYYY-MM-DD/` (use the current date). Prefer a concise `README.md` in that folder; add additional files if needed for clarity.
- **Architecture updates**: After any structural changes (e.g., adding/removing hosts, significant module moves/splits, overlays/input topology changes), update `docs/ARCHITECTURE.md` in the same PR. If it does not exist, create it with a short overview of the repository layout and key components.
- **Future-session todos**: Record outstanding items in `docs/agents/todo.md`. For each item, include:
  - A one-line description
  - An estimated impact if implemented (e.g., low/medium/high, or a brief sentence)
  - A realistic time estimate to implement

### Validations Before You Finish
- Quick sanity check of flake outputs:
  ```bash
  nix flake show .
  ```
- For Darwin changes, run a build:
  ```bash
  nix --extra-experimental-features 'nix-command flakes' build .#darwinConfigurations.aarch64-darwin.system
  ```
- For activation (on macOS), run:
  ```bash
  ./result/sw/bin/darwin-rebuild switch --flake .#
  ```
- **Quick flake tests for macOS (no activation)**
  ```bash
  nix run nix-darwin -- check .#lunar
  nix run nix-darwin -- build .#lunar
  ```
- **NixOS build example (Linux only; no activation)**
  ```bash
  nix build .#nixosConfigurations.home-desktop.config.system.build.toplevel
  ```
- **Architecture-gated tests (recommended)**
  - Only run tests for the current platform:
    ```bash
    case "$(nix eval --impure --raw --expr builtins.currentSystem)" in
      aarch64-darwin)
        nix flake show .
        nix run nix-darwin -- check .#lunar
        nix run nix-darwin -- build .#lunar
        ;;
      x86_64-linux)
        nix flake show .
        nix build .#nixosConfigurations.home-desktop.config.system.build.toplevel
        ;;
    esac
    ```
- For NixOS changes, at minimum ensure `nix flake check` (if defined) and build the relevant system.

### Typical Agent Tasks (safe defaults)
- **Add a Homebrew cask or formula**: Update the appropriate module under `modules/darwin` or host `home.nix` as configured; keep it minimal.
- **Add a Home-Manager package/module**: Touch `modules/home` or the host home module; use options rather than ad-hoc scripts where possible.
- **Introduce a new host**: Create a host directory under `hosts/darwin` or `hosts/nixos`; add entries in `flake.nix` analogous to existing ones.
- **Adjust overlay**: Edit files under `overlays/`; keep changes small and documented in the diff.

### Conventions & Constraints
- Prefer Nix modules and options over shell scripts when feasible.
- Keep `flake.nix` inputs tidy; follow existing pinning/`follows` patterns.
- Avoid introducing non-reproducible steps or external network dependencies in build paths.

### Troubleshooting
- If `darwin-rebuild` fails after a build:
  - Inspect activation errors; back out the last module change; try `rollback` helper.
- If a package is missing or broken:
  - Consider using overlays or pinning to a known-good input.

### Contact & Ownership
- Primary user: `kisw` on macOS; `kirksw` on NixOS desktop.
- If unsure, prefer proposing changes via PR with a clear rationale and a reversible plan.

---

By following this guide, agents can make safe, focused improvements that build and switch cleanly without jeopardizing secrets or reproducibility.
