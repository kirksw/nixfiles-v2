{ pkgs, pkgs-unstable, lib, config, ... }:

{
  options = {
    gowish.enable = lib.mkEnableOption "enables gowish tooling";
  };

  config = lib.mkIf config.gowish.enable {
    home.packages = with pkgs; [
      # secret manager
      pkgs-unstable.infisical
    ];
  };
}
