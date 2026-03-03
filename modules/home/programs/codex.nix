{
  self,
  pkgs,
  lib,
  config,
  git,
  ...
}:

let
  system = pkgs.stdenv.hostPlatform.system;
  swePrunerMcpPkg = self.packages.${system}.swe-pruner-mcp or null;

  codexMcpSection = if config.homeModules.swePrunerMcp.enable && swePrunerMcpPkg != null then
    ''
    [mcp_servers.swe-pruner]
    command = "${swePrunerMcpPkg}/bin/swe-pruner-mcp"
    environment = { MODEL_PATH = "${config.home.homeDirectory}/.cache/swe-pruner/models/code-pruner", STATS_FILE = "${config.home.homeDirectory}/.cache/swe-pruner/stats.json" }
    ''
  else "";

  codexConfig = ''
    model = "gpt-5.3-codex"
    model_reasoning_effort = "high"

    ${codexMcpSection}

    [features]
    experimental_use_rmcp_client = true
    multi_agent = true
  '';

  mkCodexWrapper = pkgs.writeShellScriptBin "codex" ''
    set -euo pipefail

    LUNAR_KEY_PATH="${config.sops.secrets."api/lunar/openai".path}"
    GITHUB_PAT_PATH="${config.sops.secrets."git/pat".path}"
    CODEX_BIN="${pkgs.llm-agents.codex}/bin/codex"

    is_work_project() {
      [[ "$(pwd)" == ~/git/github.com/lunarway?(/*) ]]
    }

    if is_work_project; then
      if [[ ! -f "$LUNAR_KEY_PATH" ]]; then
        echo "Error: Missing API key at $LUNAR_KEY_PATH" >&2
        exit 1
      fi
      export OPENAI_BASE_URL="https://eu.api.openai.com/v1"
      export CODEX_HOME="''${HOME}/.config/lunar/codex"
      export CODEX_GITHUB_PERSONAL_ACCESS_TOKEN="$(tr -d '[:space:]' < "$GITHUB_PAT_PATH")"
      echo "codex: using work config (lunar api key)" >&2
      if ! "$CODEX_BIN" login status; then
          cat "$LUNAR_KEY_PATH" | "$CODEX_BIN" login --with-api-key
      fi
      exec "$CODEX_BIN" "$@"
    else
      export CODEX_GITHUB_PERSONAL_ACCESS_TOKEN="$(tr -d '[:space:]' < "$GITHUB_PAT_PATH")"
      echo "codex: using personal config (ChatGPT account)" >&2
      if ! "$CODEX_BIN" login status; then
          "$CODEX_BIN" login
      fi
      exec "$CODEX_BIN" "$@"
    fi
  '';
in
{
  options = {
    homeModules.codex.enable = lib.mkEnableOption "enables codex";
  };

  config = lib.mkIf config.homeModules.codex.enable {
    # NOTE: codex doesn't seem to support oauth with github mcp :/
    sops.secrets = {
      "api/lunar/openai" = {
        sopsFile = "${self}/secrets/api/lunar.yaml";
        key = "openai";
        mode = "0400";
      };
      "git/pat" = {
        sopsFile = "${self}/secrets/git/pat.yaml";
        key = "pat";
        mode = "0400";
      };
    };

    home.packages = [
      mkCodexWrapper
    ];

    home.file.".codex/config.toml".text = codexConfig;
  };
}
