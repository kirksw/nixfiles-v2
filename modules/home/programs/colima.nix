
{ pkgs, lib, config, ... }:

{
  options = {
    colima.enable = lib.mkEnableOption "enables colima tooling";
  };

  config = lib.mkIf config.colima.enable {
    home.packages = with pkgs; [
      # for linux we enable docker directly
      (lib.mkIf pkgs.stdenv.hostPlatform.isDarwin
        colima
      )
      minikube
      lazydocker
    ];
  };
}
