# NixFiles Agent Handbook

> **Purpose**: This handbook provides all context an AI agent needs to work effectively in this repository.

## Quick Reference

| Action | Command |
|--------|---------|
| **Build (macOS)** | `apps/aarch64-darwin/build` |
| **Switch (macOS)** | `apps/aarch64-darwin/switch` |
| **Rollback (macOS)** | `apps/aarch64-darwin/rollback` |
| **Check flake** | `nix flake check` |
| **Update packages** | `nix run .#update-packages` |
| **Update flake inputs** | `nix flake update` |

---

## 1. Architecture Overview

```
nixfiles-v2/
├── flake.nix           # Entry point - defines systems & inputs
├── lib/                # Helper functions for building systems
│   ├── darwin.nix      # macOS system builder
│   ├── nixos.nix       # Linux system builder
│   ├── homemanager.nix # Home-manager integration
│   └── app.nix         # App builders (build/switch/rollback)
├── hosts/              # Host-specific configurations
│   ├── darwin/work/    # macOS "lunar" host
│   └── nixos/          # Linux hosts (ry6a, ry6b)
├── modules/            # Reusable modules (EDIT THESE)
│   ├── darwin/         # macOS-specific modules
│   ├── home/           # Home-manager modules (programs/services)
│   ├── nixos/          # NixOS-specific modules
│   └── shared/         # Cross-platform modules
├── config/             # Dotfiles symlinked by modules
├── packages/           # Custom package definitions
├── overlays/           # Package overlays
├── secrets/            # SOPS-encrypted secrets (YAML)
└── scripts/            # ZSH plugins and helper scripts
```

### Key Concepts

1. **Systems are defined in `flake.nix`** under `darwinSystems` and `nixosSystems`
2. **Modules auto-import** from subdirectories of `modules/*/` (see `default.nix` patterns)
3. **Dotfiles live in `config/`** and are symlinked via home-manager
4. **Secrets use SOPS** with age keys (see `.sops.yaml`)

---

## 2. Module Pattern

All modules follow this pattern (`modules/home/template.nix`):

```nix
{ pkgs, lib, config, ... }:

{
  options = {
    module.<name>.enable = lib.mkEnableOption "enables <name>";
  };

  config = lib.mkIf config.module.<name>.enable {
    # Programs, packages, files here
  };
}
```

### Adding a New Module

1. Copy `modules/home/template.nix` to `modules/home/programs/<name>.nix`
2. Replace `module.<name>` with your module name
3. Enable it in host config or set a default in `modules/home/default.nix`

### Module Categories

| Path | Purpose |
|------|---------|
| `modules/home/programs/` | User programs (ghostty, tmux, zsh, etc.) |
| `modules/home/services/` | User services (homerow, etc.) |
| `modules/darwin/services/` | macOS services (aerospace, jankyborders) |
| `modules/darwin/programs/` | macOS programs (homebrew) |
| `modules/nixos/generic/` | NixOS services (k3s) |

---

## 3. Host Configuration

### Current Systems

| Name | Platform | User | Purpose |
|------|----------|------|---------|
| `lunar` | aarch64-darwin | kisw | Primary macOS workstation |
| `nixos-ry6a` | x86_64-linux | root | Server/k3s node |

### Modifying a Host

- **macOS host config**: `hosts/darwin/work/default.nix`
- **macOS home config**: `hosts/darwin/work/home.nix`
- **NixOS host config**: `hosts/nixos/<name>/default.nix`

---

## 4. Secrets Management (SOPS)

### Rules

- **NEVER commit plaintext secrets**
- All secrets in `secrets/` are encrypted with age
- Keys defined in `.sops.yaml`

### Working with Secrets

```bash
# Edit a secret (decrypts in-place)
sops secrets/ssh/default.yaml

# Create a new secret
sops secrets/new-category/new-secret.yaml
```

### Secret Categories

| Path | Purpose |
|------|---------|
| `secrets/git/` | Git signing keys and configs |
| `secrets/ssh/` | SSH private keys |
| `secrets/k8s/` | Kubernetes configs |

---

## 5. Homebrew Integration

macOS uses `nix-homebrew` for Homebrew management:

- **Casks** (GUI apps): `modules/darwin/casks.nix`
- **Brews** (CLI tools): `modules/darwin/brews.nix`
- **Taps**: `modules/darwin/programs/homebrew.nix`

---

## 6. Custom Packages

Packages in `packages/*/` are auto-discovered and available via:

```bash
nix build .#<package-name>
nix run .#update-packages  # Update all packages
```

---

## 7. Development Workflow

### Making Changes

1. **Edit modules** in `modules/` (prefer existing modules over new ones)
2. **Build to test**: `apps/aarch64-darwin/build`
3. **Switch to apply**: `apps/aarch64-darwin/switch`
4. **Commit changes** with descriptive messages

### Common Tasks

| Task | Where to Edit |
|------|---------------|
| Add a package | `modules/home/programs/baseline.nix` or relevant module |
| Add a macOS app | `modules/darwin/casks.nix` |
| Add a CLI tool via brew | `modules/darwin/brews.nix` |
| Configure a program | Create/edit module in `modules/home/programs/` |
| Add dotfiles | Add to `config/`, symlink in module |

### Testing

See [Section 12: Testing the Flake](#12-testing-the-flake) for comprehensive examples.

---

## 8. Overlays

Custom overlays in `overlays/*/` modify or add packages:

```nix
# Example: overlays/colima/default.nix
final: prev: {
  colima = prev.colima.overrideAttrs (old: {
    # modifications
  });
}
```

Enable overlays in `flake.nix` under the system's `overlays` list.

---

## 9. Agent Session Protocol

### Starting a Session

1. Read this handbook
2. Check `docs/agents/todo.md` for pending tasks
3. Review recent changes with `git log --oneline -10`

### During a Session

- **Prefer editing** existing modules over creating new ones
- **Test changes** with `build` before `switch`
- **Update todo.md** as tasks are completed

### Ending a Session

1. Ensure all changes are committed
2. Update `docs/agents/todo.md` with:
   - Completed tasks
   - New tasks discovered
   - Any blockers

---

## 10. Useful Aliases

These aliases are available in the shell:

| Alias | Command | Purpose |
|-------|---------|---------|
| `ns` | switch command | Apply configuration changes |
| `nu` | nix flake update | Update flake inputs |

---

## 11. Troubleshooting

### Build Fails

1. Check syntax: `nix flake check`
2. Look for specific error in build output
3. Common issues:
   - Missing import in module
   - Typo in option name
   - Package not in nixpkgs

### Switch Fails

1. Try build first to isolate issue
2. Check if service failed to start
3. Rollback if needed: `apps/aarch64-darwin/rollback`

### Secrets Issues

1. Verify age key is available
2. Check `.sops.yaml` rules match file path
3. Re-encrypt if key changed: `sops updatekeys <file>`

---

## 12. Testing the Flake

### Quick Validation

```bash
# Check flake syntax and evaluate all outputs
nix flake check

# Show all flake outputs (systems, packages, apps)
nix flake show
```

### Building Without Applying

```bash
# Build macOS configuration (doesn't activate)
apps/aarch64-darwin/build

# Build specific system configuration
nix build .#darwinConfigurations.lunar.system

# Build a NixOS configuration
nix build .#nixosConfigurations.nixos-ry6a.config.system.build.toplevel
```

### Evaluating Expressions

```bash
# Check if a specific option evaluates correctly
nix eval .#darwinConfigurations.lunar.config.system.stateVersion

# List all packages in baseline module (example)
nix eval .#darwinConfigurations.lunar.config.home-manager.users.kisw.home.packages --apply 'map (p: p.name)'

# Check a module option exists
nix eval .#darwinConfigurations.lunar.options.module.zsh.enable
```

### Interactive Testing with REPL

```bash
# Start a REPL with flake loaded
nix repl .#

# Then explore interactively:
# > darwinConfigurations.lunar.config.home-manager.users.kisw.home.packages
# > :p nixosConfigurations.nixos-ry6a.config.services
```

### Testing Individual Packages

```bash
# Build a custom package from packages/
nix build .#treekanga
nix build .#proton-pass-cli

# Run update scripts for packages
nix run .#update-packages
```

### Dry-Run Activation

```bash
# macOS: See what would change without applying
darwin-rebuild build --flake .#lunar

# NixOS: Dry-run activation
nixos-rebuild dry-activate --flake .#nixos-ry6a
```

### Testing Module Changes

```bash
# 1. Make your changes to a module

# 2. Check for syntax errors
nix flake check

# 3. Build to catch evaluation errors
apps/aarch64-darwin/build

# 4. If successful, apply
apps/aarch64-darwin/switch
```

### Debugging Build Failures

```bash
# Get verbose output
nix build .#darwinConfigurations.lunar.system --show-trace

# Check specific derivation
nix log /nix/store/<hash>-<name>

# Build with debug info
nix build .#darwinConfigurations.lunar.system -L
```

### Testing Home-Manager Separately

```bash
# Evaluate home-manager config
nix eval .#darwinConfigurations.lunar.config.home-manager.users.kisw.home.stateVersion

# Check which programs are enabled
nix eval .#darwinConfigurations.lunar.config.home-manager.users.kisw.programs --apply builtins.attrNames
```

### Validating Secrets

```bash
# Verify SOPS can decrypt (requires age key)
sops -d secrets/ssh/default.yaml

# Check .sops.yaml is valid
sops updatekeys --dry-run secrets/ssh/default.yaml
```

### Common Test Scenarios

| Scenario | Command |
|----------|---------|
| "Does my flake parse?" | `nix flake check` |
| "What will this build?" | `nix flake show` |
| "Will my config build?" | `apps/aarch64-darwin/build` |
| "What's in this option?" | `nix eval .#darwinConfigurations.lunar.config.<path>` |
| "Debug build failure" | `nix build ... --show-trace` |
| "Test without risk" | `darwin-rebuild build --flake .#lunar` |

---

## File Quick Reference

| What | Where |
|------|-------|
| Main flake | `flake.nix` |
| macOS host | `hosts/darwin/work/` |
| Home modules | `modules/home/programs/` |
| Darwin modules | `modules/darwin/` |
| Dotfiles | `config/` |
| Secrets | `secrets/` |
| This handbook | `docs/agents/README.md` |
| Task list | `docs/agents/todo.md` |
