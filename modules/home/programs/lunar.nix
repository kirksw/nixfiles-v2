{ pkgs, lib, config, ... }:

{
  options = {
    lunar.enable = lib.mkEnableOption "enables lunar tooling";
  };

  config = lib.mkIf config.lunar.enable {
    home.packages = with pkgs; [
      # secret manager
      kubeseal
      awscli2
      hamctl
      shuttle
    ];

    # home.sessionVariables = {
    #   HAMCTL_URL="https://release-manager.lunar.tech";
    #   HAMCTL_OAUTH_IDP_URL="https://login.lunar.tech/oauth2/ausains2eoZqaXcLD417";
    #   HAMCTL_OAUTH_CLIENT_ID="0oaaintlyqqOETKhA417";
    # };
  };
}
