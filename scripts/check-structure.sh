#!/usr/bin/env bash
set -euo pipefail

fail=0

err() {
  echo "ERROR: $*" >&2
  fail=1
}

for domain in home darwin nixos shared; do
  if [[ ! -f "modules/${domain}/imports.nix" ]]; then
    err "Missing modules/${domain}/imports.nix"
  fi

done

for domain in home darwin nixos shared; do
  if rg -n "listFilesRecursive" "modules/${domain}/default.nix" >/dev/null; then
    err "Recursive auto-import is not allowed in modules/${domain}/default.nix"
  fi

  if ! rg -n "imports\s*=\s*import\s+\./imports\.nix;" "modules/${domain}/default.nix" >/dev/null; then
    err "modules/${domain}/default.nix must import ./imports.nix"
  fi

done

if rg -n "^[[:space:]]+[a-zA-Z0-9_-]+\\.enable = lib\\.mkEnableOption" modules/home >/dev/null; then
  err "Home modules must define option toggles under homeModules.<name>.enable"
fi

if rg -n "^[[:space:]]+[a-zA-Z0-9_-]+\\.enable = lib\\.mkEnableOption" modules/darwin >/dev/null; then
  err "Darwin modules must define option toggles under darwinModules.<name>.enable"
fi

if rg -n "options\\.my\\.|config\\.my\\." modules/nixos >/dev/null; then
  err "NixOS modules must use nixosModules.<name> namespace"
fi

if rg -n "nixpkgs\s*=\s*\{[[:space:][:print:]]*overlays" modules/shared >/dev/null; then
  err "Shared modules must not set overlays; overlays are assembled in flake/overlays.nix"
fi

if [[ "$fail" -ne 0 ]]; then
  exit 1
fi

echo "Structure checks passed."
