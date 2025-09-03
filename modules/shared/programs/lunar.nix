{
  inputs,
  pkgs,
  lib,
  config,
  ...
}:

{
  options = {
    lunar-tools.enable = lib.mkEnableOption "enables lunar tooling";
  };

  config = lib.mkIf config.lunar-tools.enable {
    environment.systemPackages = [
      inputs.lunar-tools.packages.${pkgs.system}.hamctl
      inputs.lunar-tools.packages.${pkgs.system}.shuttle
      inputs.lunar-tools.packages.${pkgs.system}.hubble
      inputs.lunar-tools.packages.${pkgs.system}.sesh
      #inputs.lunar-tools.packages.${pkgs.system}.fuzzy-clone
      #inputs.lunar-tools.packages.${pkgs.system}.gitnow
    ];
  };
}
