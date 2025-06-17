{ pkgs, lib, config, ... }:

{
  options = {
    lunar.enable = lib.mkEnableOption "enables lunar tooling";
  };

  config = lib.mkIf config.lunar.enable {
    home.packages = with pkgs; [
      kubeseal
      awscli2
      hamctl
      shuttle
      #fuzzyclone
    ];
  };
}
