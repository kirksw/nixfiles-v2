{ pkgs, lib, config, ... }:

{
  options = {
    colima.enable = lib.mkEnableOption "enables colima tooling";
  };

  config = lib.mkIf config.colima.enable {
    home.packages = with pkgs; [
      (lib.mkIf pkgs.stdenv.hostPlatform.isDarwin
        colima
        lima-additional-guestagents
      )
      minikube
      lazydocker
    ];
  };
}
