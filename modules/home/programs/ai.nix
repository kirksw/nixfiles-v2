{
  pkgs,
  pkgs-unstable,
  lib,
  config,
  nixDirectory,
  ...
}:

{
  options = {
    homeModules.aidev.enable = lib.mkEnableOption "enables ai dev tooling";
  };

  config = lib.mkIf config.homeModules.aidev.enable {
    home.packages = with pkgs-unstable; [
      ollama
    ];
  };
}
