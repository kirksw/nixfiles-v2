{
  pkgs,
  lib,
  config,
  nixDirectory,
  ...
}:

{
  options = {
    sketchybar.enable = lib.mkEnableOption "enables sketchybar";
  };

  config = lib.mkIf config.sketchybar.enable {
    programs.sketchybar = {
      enable = true;

      extraPackages = with pkgs; [
        jq
      ];

      #config = {
      #  source = "${self}/config/sketchybar";
      #  recursive = true;
      #};
    };

    xdg.configFile = {
      "sketchybar" = {
        source = config.lib.file.mkOutOfStoreSymlink "${nixDirectory}/config/sketchybar";
        recursive = true;
      };
    };
  };
}
