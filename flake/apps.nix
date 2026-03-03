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
    export repo_root="$(${pkgs.git}/bin/git rev-parse --show-toplevel 2>/dev/null || ${pkgs.coreutils}/bin/pwd)"
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
    source_opencode_agents="$repo_root/agents/opencode/agents"
    source_opencode_agents_guide="$repo_root/agents/opencode/AGENTS.md"
    source_shared_skills="$repo_root/agents/skills"
    source_pi_agents="$repo_root/agents/pi/agents"
    source_pi_agents_guide="$repo_root/agents/pi/AGENTS.md"
    source_pi_extensions="$repo_root/agents/pi/extensions"
    source_pi_prompts="$repo_root/agents/pi/prompts"

    target_opencode_root="$HOME/.config/opencode"
    target_opencode_agents="$target_opencode_root/agents"
    target_opencode_skills="$target_opencode_root/skills"
    target_opencode_agents_guide="$target_opencode_root/AGENTS.md"

    target_pi_root="$HOME/.pi/agent"
    target_pi_agents="$target_pi_root/agents"
    target_pi_skills="$target_pi_root/skills"
    target_pi_extensions="$target_pi_root/extensions"
    target_pi_prompts="$target_pi_root/prompts"
    target_pi_agents_guide="$target_pi_root/AGENTS.md"

    if [ ! -d "$source_opencode_agents" ]; then
      echo "Missing source directory: $source_opencode_agents" >&2
      exit 1
    fi

    if [ ! -f "$source_opencode_agents_guide" ]; then
      echo "Missing source file: $source_opencode_agents_guide" >&2
      exit 1
    fi

    if [ ! -d "$source_shared_skills" ]; then
      echo "Missing source directory: $source_shared_skills" >&2
      exit 1
    fi

    if [ ! -d "$source_pi_agents" ]; then
      echo "Missing source directory: $source_pi_agents" >&2
      exit 1
    fi

    if [ ! -f "$source_pi_agents_guide" ]; then
      echo "Missing source file: $source_pi_agents_guide" >&2
      exit 1
    fi

    if [ ! -d "$source_pi_extensions" ]; then
      echo "Missing source directory: $source_pi_extensions" >&2
      exit 1
    fi

    if [ ! -d "$source_pi_prompts" ]; then
      echo "Missing source directory: $source_pi_prompts" >&2
      exit 1
    fi

    ${pkgs.coreutils}/bin/mkdir -p \
      "$target_opencode_agents" \
      "$target_opencode_skills" \
      "$target_pi_agents" \
      "$target_pi_skills" \
      "$target_pi_extensions" \
      "$target_pi_prompts"

    ${pkgs.coreutils}/bin/cp -R "$source_opencode_agents"/. "$target_opencode_agents"/
    ${pkgs.coreutils}/bin/cp -R "$source_shared_skills"/. "$target_opencode_skills"/
    ${pkgs.coreutils}/bin/cp "$source_opencode_agents_guide" "$target_opencode_agents_guide"

    ${pkgs.coreutils}/bin/cp -R "$source_pi_agents"/. "$target_pi_agents"/
    ${pkgs.coreutils}/bin/cp -R "$source_shared_skills"/. "$target_pi_skills"/
    ${pkgs.coreutils}/bin/cp -R "$source_pi_extensions"/. "$target_pi_extensions"/
    ${pkgs.coreutils}/bin/cp -R "$source_pi_prompts"/. "$target_pi_prompts"/
    ${pkgs.coreutils}/bin/cp "$source_pi_agents_guide" "$target_pi_agents_guide"

    echo "Synced OpenCode assets to $target_opencode_root"
    echo "Synced pi assets to $target_pi_root"
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
      description = "Copy repository agents/skills to OpenCode and pi config directories.";
    };
  };
}
