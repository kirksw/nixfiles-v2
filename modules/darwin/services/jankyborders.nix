{
  lib,
  config,
  ...
}:

{
  options = {
    jankyborders.enable = lib.mkEnableOption "enables sketchybar";
  };

  config = lib.mkIf config.jankyborders.enable {
    services.jankyborders = {
      enable = true;
      width = 8.0;
      hidpi = true;
      active_color = "0xFFFFFF";
      inactive_color = "0xCCCCCC";
    };
  };
}
