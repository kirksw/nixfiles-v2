# Agent Task List

> Track pending, in-progress, and completed tasks for agent sessions.

## Current Session

_No active session tasks._

---

## Backlog

### High Priority

- [x] Validate and document Linux host example build (from README roadmap)
- [x] Reimplement macOS Dock setup via nix-darwin module (from README roadmap)

### Medium Priority

- [ ] Review and update module documentation as needed
- [ ] Add example for creating new custom package

### Low Priority

- [x] Add pre-commit hooks for nix formatting
- [x] Consider adding CI workflow for flake checks

---

## Completed

### 2026-02-02

- [x] Created `docs/agents/` directory structure
- [x] Wrote comprehensive agent handbook (`README.md`)
- [x] Created this task tracking file (`todo.md`)

### 2026-02-08

- [x] Implemented `apps/x86_64-linux/build` for host-specific NixOS builds
- [x] Extracted macOS Dock defaults into `modules/darwin/services/dock.nix` and enabled it for the work host
- [x] Added `.pre-commit-config.yaml` with `nix fmt` hook and allowed tracking in `.gitignore`
- [x] Added CI workflow `.github/workflows/flake-check.yml` for `nix flake check --no-build` and `nix build .#swe-pruner-mcp`

---

## Session Log Format

When completing a session, add an entry:

```markdown
### YYYY-MM-DD

- [x] Task completed
- [x] Another task
- [ ] Task moved to backlog (reason)
```
