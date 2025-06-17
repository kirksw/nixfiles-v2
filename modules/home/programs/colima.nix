
{ pkgs, lib, config, ... }:

{
  options = {
    colima.enable = lib.mkEnableOption "enables colima tooling";
  };

  config = lib.mkIf config.colima.enable {
    home.packages = with pkgs; [
      # pkgs.lima.override {
      #   withAdditionalGuestAgents = true;
      # }
      # for linux we enable docker directly
      (lib.mkIf pkgs.stdenv.hostPlatform.isDarwin
        colima
      )
      minikube
      lazydocker
      lima-additional-guestagents
    ];
  };
}
