{ nixpkgs, mylibs }:
{
  system,
  appCommands ? [
    "build"
    "switch"
    "rollback"
  ],
  packageNames,
  packages,
}:
let
  pkgs = import nixpkgs { inherit system; };
  updateCommandFor =
    name:
    let
      pkg = packages.${name};
      passthru = pkg.passthru or { };
    in
    if passthru ? updateScript then
      toString passthru.updateScript
    else
      "echo 'No updateScript for ${name}'";

  updateAllPackages = pkgs.writeShellScriptBin "update-packages" ''
    set -euo pipefail
    repo_root="$(${pkgs.git}/bin/git rev-parse --show-toplevel 2>/dev/null || ${pkgs.coreutils}/bin/pwd)"
    cd "$repo_root"
    echo "Updating all packages..."
    ${builtins.concatStringsSep "\n" (
      map (name: ''
        echo "-> Updating ${name}..."
        ${updateCommandFor name}
      '') packageNames
    )}
    echo "Done!"
  '';

  syncAgents = pkgs.writeShellScriptBin "sync-agents" ''
    set -euo pipefail

    repo_root="$(${pkgs.git}/bin/git rev-parse --show-toplevel 2>/dev/null || ${pkgs.coreutils}/bin/pwd)"
    source_agents="$repo_root/agents/agents"
    source_skills="$repo_root/agents/skills"
    target_root="$HOME/.config/opencode"
    target_agents="$target_root/agents"
    target_skills="$target_root/skills"

    if [ ! -d "$source_agents" ]; then
      echo "Missing source directory: $source_agents" >&2
      exit 1
    fi

    if [ ! -d "$source_skills" ]; then
      echo "Missing source directory: $source_skills" >&2
      exit 1
    fi

    ${pkgs.coreutils}/bin/mkdir -p "$target_agents" "$target_skills"
    ${pkgs.coreutils}/bin/cp -R "$source_agents"/. "$target_agents"/
    ${pkgs.coreutils}/bin/cp -R "$source_skills"/. "$target_skills"/

    echo "Synced OpenCode assets to $target_root"
  '';
in
(
  builtins.listToAttrs (
    map (name: {
      inherit name;
      value = mylibs.app.mkApp name system;
    }) appCommands
  )
)
// {
  update-packages = {
    type = "app";
    program = "${updateAllPackages}/bin/update-packages";
    meta = {
      description = "Run update scripts for custom packages in this repository.";
    };
  };

  sync-agents = {
    type = "app";
    program = "${syncAgents}/bin/sync-agents";
    meta = {
      description = "Copy repository agents and skills to ~/.config/opencode.";
    };
  };
}
