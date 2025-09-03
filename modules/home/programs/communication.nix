{
  pkgs,
  lib,
  config,
  ...
}:

{
  options = {
    communication.enable = lib.mkEnableOption "enables communication tooling";
  };

  config = lib.mkIf config.communication.enable {
    home.packages = with pkgs; [
      whatsapp-for-mac
      discord
    ];
  };
}
