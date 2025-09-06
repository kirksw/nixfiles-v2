{
  inputs,
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

      # internal tooling
      shuttle
      hamctl
      hubble
      sesh
      dagger
      fuzzy-clone
      gitnow
    ];
  };
}
