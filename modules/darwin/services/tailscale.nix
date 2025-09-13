{
  lib,
  config,
  ...
}:

{
  options = {
    tailscale.enable = lib.mkEnableOption "enables tailscale mods";
  };

  config = lib.mkIf config.tailscale.enable {
    services.tailscale = {
      enable = true;
    };
  };
}
