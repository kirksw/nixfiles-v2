{
  pkgs,
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
    home.packages = with pkgs; [
      opencode
      claude-code
      claude-code-router
      ollama
    ];

    xdg.configFile = {
      "opencode" = {
        source = config.lib.file.mkOutOfStoreSymlink "${nixDirectory}/config/opencode/";
        recursive = true;
      };
    };
  };
}
