{
  self,
  pkgs,
  lib,
  config,
  ...
}:

let
  cursorMcpConfig = lib.mkIf config.homeModules.swePrunerMcp.enable {
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
in
{
  options = {
    homeModules.cursor.enable = lib.mkEnableOption "enables cursor editor";
  };

  config = lib.mkIf config.homeModules.cursor.enable {
    home.file.".cursor/mcp.json".text = builtins.toJSON cursorMcpConfig;
  };
}
