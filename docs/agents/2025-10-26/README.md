# 2025-10-26 Agent Session

## Summary
- Removed inline TODOs in `modules/home/programs/developer.nix` and `modules/home/programs/zsh.nix`
- Made AWS dbt profiles dynamic in `scripts/lunar/modules/lunar-aws.zsh`
- Replaced README TODOs with a concise Roadmap
- Pruned obsolete items in `docs/agents/todo.md`
- Implemented `apps/x86_64-linux/switch` helper for NixOS

## Rationale
- Keep repo free of stale TODOs to improve signal-to-noise
- Reduce manual steps (dynamic AWS profiles)
- Clarify user-facing docs; keep Linux guidance aligned

## Test plan
- macOS: `nix --extra-experimental-features 'nix-command flakes' build .#darwinConfigurations.aarch64-darwin.system`
- Linux: `nix build .#nixosConfigurations.home-desktop.config.system.build.toplevel`
- AWS script: run `rebuild_aws_config <session> <start_url> <region>`; verify profiles rendered; `aws_fzf_profile` selects and exports `AWS_PROFILE`
- Linux switch helper: `apps/x86_64-linux/switch home-desktop` (on Linux)

## Follow-ups
- Optional overlay example (e.g., neovim-nightly)
- Reimplement macOS Dock setup via nix-darwin module
