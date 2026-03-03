{
  lib,
  self,
}:

{
  mkSwePrunerMcpForSystem = pkgs: config: {
    command = "${self.packages.${pkgs.stdenv.hostPlatform.system}.swe-pruner-mcp}/bin/swe-pruner-mcp";
    environment = {
      MODEL_PATH = "${config.home.homeDirectory}/.cache/swe-pruner/models/code-pruner";
      STATS_FILE = "${config.home.homeDirectory}/.cache/swe-pruner/stats.json";
    };
  };

  mkCursorMcpJson = pkgs: config: {
    mcpServers = {
      swe-pruner = {
        command = "${self.packages.${pkgs.stdenv.hostPlatform.system}.swe-pruner-mcp}/bin/swe-pruner-mcp";
        env = {
          MODEL_PATH = "${config.home.homeDirectory}/.cache/swe-pruner/models/code-pruner";
          STATS_FILE = "${config.home.homeDirectory}/.cache/swe-pruner/stats.json";
        };
      };
    };
  };

  mkCodexMcpToml = pkgs: config: ''
    [mcp_servers.swe-pruner]
    command = "${self.packages.${pkgs.stdenv.hostPlatform.system}.swe-pruner-mcp}/bin/swe-pruner-mcp"
    environment = { MODEL_PATH = "${config.home.homeDirectory}/.cache/swe-pruner/models/code-pruner", STATS_FILE = "${config.home.homeDirectory}/.cache/swe-pruner/stats.json" }
  '';

  mkOpenCodeMcpEntry = pkgs: config: {
    type = "local";
    enabled = true;
    command = [ "${self.packages.${pkgs.stdenv.hostPlatform.system}.swe-pruner-mcp}/bin/swe-pruner-mcp" ];
    environment = {
      MODEL_PATH = "${config.home.homeDirectory}/.cache/swe-pruner/models/code-pruner";
      STATS_FILE = "${config.home.homeDirectory}/.cache/swe-pruner/stats.json";
    };
  };
}
