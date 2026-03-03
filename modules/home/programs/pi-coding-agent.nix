{
  pkgs,
  lib,
  config,
  ...
}:

{
  options = {
    homeModules.piCodingAgent.enable = lib.mkEnableOption "enables pi coding agent";
  };

  config = lib.mkIf config.homeModules.piCodingAgent.enable {
    home.packages = [
      pkgs.pi-coding-agent
    ];
  };
}
