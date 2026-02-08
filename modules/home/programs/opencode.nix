{
  self,
  pkgs,
  pkgs-unstable,
  lib,
  config,
  ...
}:

let
  opencodeconfig = {
    "$schema" = "https://opencode.ai/config.json";

    provider = {
      ollama = {
        npm = "@ai-sdk/openai-compatible";
        name = "ollama local models";
        options = {
          baseurl = "http://localhost:11434/v1";
          apikey = "ollama";
        };
        models = {
          "qwen2.5-coder:7b" = {
            name = "qwen 2.5 coder 7b (fast)";
          };
          "qwen2.5-coder:32b" = {
            name = "qwen 2.5 coder 32b (main)";
          };
        };
      };

      zai-coding-plan = {
        name = "zai-coding-plan";
        options = {
          apiKey = "{env:zai_token}";
        };
      };
    };

    model = "zai/glm-4.7";
    small_model = "zai/glm-4.5-air";

    compaction = {
      auto = true;
      prune = true;
    };

    watcher = {
      ignore = [ ".git/**" ];
    };

    keybinds = {
      input_submit = "return";
      input_newline = "shift+return,ctrl+return,alt+return";
    };

    mcp = {
      # fetches and extracts web page content
      "web-reader" = {
        type = "remote";
        url = "https://api.z.ai/api/mcp/web_reader/mcp";
        headers = {
          Authorization = "Bearer {env:zai_token}";
        };
      };
      # provides access to knowledge docs and code from OSS repos
      zread = {
        type = "remote";
        url = "https://api.z.ai/api/mcp/zread/mcp";
        headers = {
          Authorization = "Bearer {env:zai_token}";
        };
      };
      # web searches with real time information retrievel
      web-search-prime = {
        type = "remote";
        url = "https://api.z.ai/api/mcp/web_search_prime/mcp";
        headers = {
          Authorization = "Bearer {env:zai_token}";
        };
      };
      # vision capabilities
      zai-mcp-server = {
        type = "local";
        command = [
          "npx"
          "-y"
          "@z_ai/mcp-server"
        ];
        environment = {
          Z_AI_API_KEY = "{env:zai_token}";
          Z_AI_MODE = "ZAI";
        };
      };
      # SWE-Pruner - context-aware code pruning (WIP)
      # swe-pruner = {
      #   type = "local";
      #   command = [
      #     "python"
      #     "-m"
      #     "swe_pruner_mcp.server"
      #   ];
      #   environment = {
      #     MODEL_PATH = "${config.home.homeDirectory}/.cache/swe-pruner/models/code-pruner";
      #     STATS_FILE = "${config.home.homeDirectory}/.cache/swe-pruner/stats.json";
      #   };
      # };
    };
  };

  mkOpencodeWrapper =
    secretPath:
    pkgs.writeShellScriptBin "opencode" ''
      set -euo pipefail

      secret_path="${secretPath}"

      if [ ! -f "$secret_path" ]; then
        echo "error: secret not found at $secret_path" >&2
        echo "make sure sops is enabled and secrets are activated" >&2
        exit 1
      fi

      if [ ! -r "$secret_path" ]; then
        echo "error: cannot read secret at $secret_path" >&2
        exit 1
      fi

      export zai_token=$(cat "$secret_path")

      exec ${pkgs-unstable.opencode}/bin/opencode "$@"
    '';
in
{
  options = {
    homeModules.opencode.enable = lib.mkEnableOption "enables opencode";
  };

  config = lib.mkIf config.homeModules.opencode.enable {
    sops.secrets = {
      "zai" = {
        sopsFile = "${self}/secrets/api/default.yaml";
        key = "zai";
        mode = "0400";
      };
    };

    home.packages = [
      (mkOpencodeWrapper config.sops.secrets."zai".path)
    ];

    xdg.configFile."opencode/opencode.json".text = builtins.toJSON opencodeconfig;
  };
}
