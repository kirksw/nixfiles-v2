{
  self,
  pkgs,
  lib,
  config,
  git,
  ...
}:

let
  mkCodexWrapper = pkgs.writeShellScriptBin "codex" ''
    set -euo pipefail

    LUNAR_KEY_PATH="${config.sops.secrets."api/lunar/openai".path}"
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
      echo "codex: using work config (lunar api key)" >&2
      if ! "$CODEX_BIN" login status; then
          cat "$LUNAR_KEY_PATH" | exec "$CODEX_BIN" login --with-api-key
      fi
      exec "$CODEX_BIN" "$@"
    else
      echo "codex: using personal config (ChatGPT account)" >&2
      if ! "$CODEX_BIN" login status; then
          exec "$CODEX_BIN" login
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
    sops.secrets = {
      "api/lunar/openai" = {
        sopsFile = "${self}/secrets/api/lunar.yaml";
        key = "openai";
        mode = "0400";
      };
    };

    home.packages = [
      mkCodexWrapper
    ];
  };
}
