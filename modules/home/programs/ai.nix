{
  pkgs,
  lib,
  config,
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
    ];
  };
}
