{
  lib,
  config,
  ...
}:

{
  options = {
    sketchybar.enable = lib.mkEnableOption "enables sketchybar";
  };

  config = lib.mkIf config.sketchybar.enable {
    services.sketchybar = {
      enable = true;
      config = ''
        sketchybar --bar height=24
        sketchybar --update
      '';
    };
  };
}
