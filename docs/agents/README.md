# NixFiles Agent Handbook

This handbook is the single source of truth for AI agents (and humans) working in this repository. It combines architectural documentation with operational protocols.

## 1. Mission & Scope

- **Goal**: Maintain macOS (nix-darwin) and NixOS configurations via Nix flakes.
- **Principles**:
  - Make minimal, high-quality edits.
  - Keep builds reproducible.
  - **Zero-tolerance** for plaintext secrets (use SOPS).

## 2. Architecture Overview

### Top-Level Structure
- `flake.nix`: Entry point defining inputs, systems, and outputs.
- `flake.lock`: Pinned dependencies.
- `lib/`: Custom builders and helpers.
- `hosts/`: Host-specific configurations (entry points for systems).
- `modules/`: Reusable Nix modules (`darwin`, `home`, `nixos`, `shared`).
- `overlays/`: Custom package overlays.
- `secrets/`: Encrypted secret definitions (SOPS).
- `apps/`: Convenience scripts for lifecycle management.

### System Map
- **macOS (Active)**:
  - **Host**: `lunar` (`aarch64-darwin`)
  - **User**: `kisw`
  - **Modules**: `hosts/darwin/work`, `modules/darwin`
  - **Features**: Homebrew, Aerospace, Tailscale, Rosetta.
- **NixOS**:
  - **Host**: `home-desktop` (`x86_64-linux`)
    - **User**: `kirksw`
  - **Host**: `nixos-ry6a` (`x86_64-linux`)
    - **User**: `root`

### Component Details
- **Libraries (`lib/`)**:
  - `darwin.nix`: `mkDarwinSystem` - Injects overlays, sops-nix, home-manager.
  - `nixos.nix`: `mkNixosSystem` - Adds disko, sops-nix.
  - `homemanager.nix`: `mkHomeManagerModule` - Standardizes HM configuration across platforms.
- **Modules (`modules/`)**:
  - `shared/`: Cross-platform config (overlays, common shells).
  - `darwin/` & `nixos/`: Platform-specific system settings.
  - `home/`: User-space programs (neovim, zsh, tmux, etc.).
  - **Auto-import**: Most `default.nix` files recursively import their subdirectories.

### Configuration Flow
1. `flake.nix` selects a host from `darwinSystems` or `nixosSystems`.
2. `lib/` functions compose the system:
   - Base platform modules + Overlays + SOPS.
   - Host module (`hosts/.../default.nix`).
   - Home Manager module (generated via `lib/homemanager.nix` pointing to `hosts/.../home.nix`).
3. Resulting derivation is built/activated.

## 3. Operational Workflows

### macOS (`aarch64-darwin`)
Prefer the convenience scripts in `apps/` but know the manual equivalents.

| Action | Script | Manual Command |
|--------|--------|----------------|
| **Build** | `apps/aarch64-darwin/build` | `nix build .#darwinConfigurations.lunar.system` |
| **Switch** | `apps/aarch64-darwin/switch` | `./result/sw/bin/darwin-rebuild switch --flake .#` |
| **Rollback** | `apps/aarch64-darwin/rollback` | *(Interactive script only)* |

### Linux (`x86_64-linux`)
Currently relies on manual flake commands or `deploy-rs`.

- **Build**: `nix build .#nixosConfigurations.HOSTNAME.config.system.build.toplevel`
- **Deploy Remote**: `deploy .#HOSTNAME` (if `deploy-rs` configured) or `nixos-rebuild switch --flake .#HOSTNAME --target-host ...`

### Secrets (SOPS)
- **Location**: `secrets/`
- **Tool**: `sops-nix` (via `sops` CLI)
- **Workflow**:
  1. Edit: `sops secrets/ssh/kisw.yaml`
  2. Reference in Nix: `config.sops.secrets."ssh/kisw/private".path`
  3. **NEVER** commit decrypted files.

## 4. Agent Protocol

### Editing Rules
1.  **Read First**: Understand the context before writing.
2.  **Minimal Changes**: Focus on the requested task.
3.  **Style**: Clear variable names, guard clauses, minimal nesting.
4.  **Safety**: Run validations before finishing.

### Documentation Standards
**Agents must adhere to the following logging rules:**

1.  **Session Documentation**:
    - Create/Update `docs/agents/YYYY-MM-DD/README.md` (today's date).
    - Content must include:
      - **Summary**: High-level overview of changes.
      - **Changes**: Technical details (files touched, modules added).
      - **Verification**: Commands run to test.
      - **Next Steps**: Any manual actions required by the user.

2.  **Architecture Updates**:
    - If you modify the repository structure (e.g., add a new host, change `lib/` logic, move modules):
      - **Update Section 2 (Architecture Overview)** of this file (`docs/agents/README.md`).

3.  **Task Tracking**:
    - Maintain `docs/agents/todo.md`.
    - Add new ideas or tech debt found during the session.
    - Mark completed items.

### Commit Strategy
- **Format**: Conventional Commits (e.g., `feat(darwin): add ghostty terminal`).
- **Scope**: Keep commits atomic (one logical change per commit).
- **Message**: focus on the "why".

## 5. Validation & Troubleshooting

### Pre-Flight Checks
```bash
# Flake Check
nix flake show .

# Darwin Dry-Run
nix run nix-darwin -- check .#lunar
nix run nix-darwin -- build .#lunar
```

### Common Issues
- **Build Fails**: Check `flake.lock` sync, overlays, or syntax errors.
- **Activation Fails**: Often due to conflicting existing files. Use `rollback` or manual cleanup.
- **Missing Package**: Check overlays or `nixpkgs` input version.

## 6. Contact & Ownership
- **Primary**: `kisw` (macOS), `kirksw` (Linux).
- **Repository**: `github.com/kirksw/nixfiles-v2`
