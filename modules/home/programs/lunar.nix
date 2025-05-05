{ pkgs, lib, config, ... }:

{
  options = {
    lunar.enable = lib.mkEnableOption "enables lunar tooling";
  };

  config = lib.mkIf config.lunar.enable {
    home.packages = with pkgs; [
      # secret manager
      awscli2
      saml2aws
    ];
    
  };
}
