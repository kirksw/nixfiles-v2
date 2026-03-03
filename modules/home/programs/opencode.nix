{
  self,
  pkgs,
  pkgs-unstable,
  lib,
  config,
  ...
}:

let
  swePrunerMcpPkg = self.packages.${pkgs.stdenv.hostPlatform.system}.swe-pruner-mcp;
  swePrunerStatsFile = "${config.home.homeDirectory}/.cache/swe-pruner/stats.json";
  swePrunerModelPath = "${config.home.homeDirectory}/.cache/swe-pruner/models/code-pruner";

  mcpConfig = {
    # fetches and extracts web page content
    "web-reader" = {
      type = "remote";
      url = "https://api.z.ai/api/mcp/web_reader/mcp";
      enabled = false;
      headers = {
        Authorization = "Bearer {env:zai_token}";
      };
    };
    # provides access to knowledge docs and code from OSS repos
    zread = {
      type = "remote";
      url = "https://api.z.ai/api/mcp/zread/mcp";
      enabled = false;
      headers = {
        Authorization = "Bearer {env:zai_token}";
      };
    };
    # web searches with real time information retrievel
    web-search-prime = {
      type = "remote";
      url = "https://api.z.ai/api/mcp/web_search_prime/mcp";
      enabled = false;
      headers = {
        Authorization = "Bearer {env:zai_token}";
      };
    };
    # vision capabilities
    zai-mcp-server = {
      type = "local";
      enabled = false;
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
  }
  // lib.optionalAttrs config.homeModules.swePrunerMcp.enable {
    swe-pruner = {
      type = "local";
      enabled = true;
      command = [ "${swePrunerMcpPkg}/bin/swe-pruner-mcp" ];
      environment = {
        MODEL_PATH = swePrunerModelPath;
        STATS_FILE = swePrunerStatsFile;
      };
    };
  };

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
          "qwen3.5-coder:9b" = {
            name = "qwen 3.5 coder 9b (fast)";
          };
          "qwen3.5-coder:35b" = {
            name = "qwen 3.5 coder 35b (main)";
          };
        };
      };

      zai-coding-plan = {
        name = "zai-coding-plan";
        options = {
          apiKey = "{env:zai_token}";
        };
      };

      anthropic = {
        name = "anthropic";
      };

      openai = {
        name = "openai";
      };
    };

    agent = {
      explore = {
        model = "openai/gpt-5.3-codex";
      };
    };

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

    mcp = mcpConfig;
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

      exec -a opencode ${pkgs-unstable.opencode}/bin/opencode "$@"
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
