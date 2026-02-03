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
    aidev.enable = lib.mkEnableOption "enables ai dev tooling";
  };

  config = lib.mkIf config.aidev.enable {
    home.packages = with pkgs-unstable; [
      claude-code
      ollama
    ];
  };
}
