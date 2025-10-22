# Agent TODOs

Each item includes a brief rationale/impact and a rough effort estimate.

- Fix NixOS SOPS module reference in `lib/nixos.nix`
  - Impact: High (enables correct secrets integration on NixOS)
  - Est: 10 min
- Correct path typos in `hosts/nixos/desktop/home.nix` (e.g., `moudles` -> `modules`)
  - Impact: Medium (unblocks NixOS HM build; reduces confusion)
  - Est: 15–20 min
- Validate `hosts/nixos/desktop/*` imports and assets; prune dead paths
  - Impact: Medium (stabilizes NixOS example)
  - Est: 30–45 min
- Document Linux build steps in `README.md` (flake-based), clarify `apps/*-linux` placeholders
  - Impact: Medium (onboarding clarity)
  - Est: 15–20 min
- Add overlay example (e.g., neovim-nightly) or remove TODO from `README.md`
  - Impact: Low-Medium (keeps README actionable)
  - Est: 20–30 min
- Optionally implement basic `apps/x86_64-linux/switch` using `nixos-rebuild --flake`
  - Impact: Medium (parity with macOS helpers)
  - Est: 20–30 min
