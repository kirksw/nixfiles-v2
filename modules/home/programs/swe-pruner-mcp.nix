{
  self,
  lib,
  config,
  ...
}:

let
  swe-pruner-mcp = self.pkgs.swe-pruner-mcp or null;
in
{
  options.swe-pruner-mcp.enable = lib.mkEnableOption "enables SWE-Pruner MCP server for context-aware code pruning";

  config = lib.mkIf config.swe-pruner-mcp.enable {
    assertions = [
      {
        assertion = swe-pruner-mcp != null;
        message = "swe-pruner-mcp package must be built first with 'nix build .#swe-pruner-mcp'";
      }
    ];
    home.packages = [ swe-pruner-mcp ];
  };
}
