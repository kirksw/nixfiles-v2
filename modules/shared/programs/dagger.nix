{
  inputs,
  pkgs,
  lib,
  config,
  ...
}:

{
  options = {
    dagger.enable = lib.mkEnableOption "enables dagger";
  };

  config = lib.mkIf config.dagger.enable {
    environment.systemPackages = [
      inputs.dagger.packages.${pkgs.system}.dagger
    ];
  };
}
