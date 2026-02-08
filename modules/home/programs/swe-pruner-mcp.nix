{
  self,
  pkgs,
  lib,
  config,
  ...
}:

let
  system = pkgs.stdenv.hostPlatform.system;
  swePrunerMcp = self.packages.${system}.swe-pruner-mcp or null;
in
{
  options.homeModules.swePrunerMcp.enable =
    lib.mkEnableOption "enables SWE-Pruner MCP server for context-aware code pruning";

  config = lib.mkIf config.homeModules.swePrunerMcp.enable {
    assertions = [
      {
        assertion = swePrunerMcp != null;
        message = "swe-pruner-mcp package is missing from flake outputs for this system.";
      }
    ];

    home.sessionVariables = {
      STATS_FILE = "${config.home.homeDirectory}/.cache/swe-pruner/stats.json";
      MODEL_PATH = "${config.home.homeDirectory}/.cache/swe-pruner/models/code-pruner";
    };

    home.activation.swePrunerMcpDirs = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      mkdir -p "${config.home.homeDirectory}/.cache/swe-pruner/models"
      mkdir -p "${config.home.homeDirectory}/.cache/swe-pruner"
    '';

    home.packages = [ swePrunerMcp ];
  };
}
