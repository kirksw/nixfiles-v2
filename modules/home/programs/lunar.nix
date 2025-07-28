{
  pkgs,
  lib,
  config,
  ...
}:

{
  options = {
    lunar.enable = lib.mkEnableOption "enables lunar tooling";
  };

  config = lib.mkIf config.lunar.enable {
    home.packages = with pkgs; [
      # general tooling
      kubeseal
      awscli2

      # ai
      codex

      # internal tooling
      #hamctl
      #shuttle
      #fuzzyclone
    ];
  };
}
