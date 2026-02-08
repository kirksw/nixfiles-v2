{
  self,
  lib,
  config,
  ...
}:

let
  swePrunerMcp = self.pkgs.swe-pruner-mcp or null;
in
{
  options.homeModules.swePrunerMcp.enable =
    lib.mkEnableOption "enables SWE-Pruner MCP server for context-aware code pruning";

  config = lib.mkIf config.homeModules.swePrunerMcp.enable {
    assertions = [
      {
        assertion = swePrunerMcp != null;
        message = "swe-pruner-mcp package must be built first with 'nix build .#swe-pruner-mcp'";
      }
    ];
    home.packages = [ swePrunerMcp ];
  };
}
