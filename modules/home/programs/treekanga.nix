{
  pkgs,
  lib,
  config,
  nixDirectory,
  ...
}:

{
  options = {
    treekanga.enable = lib.mkEnableOption "enables treekanga";
  };

  config = lib.mkIf config.treekanga.enable {
    home.packages = [ pkgs.treekanga ];

    xdg.configFile = {
      "treekanga" = {
        source = config.lib.file.mkOutOfStoreSymlink "${nixDirectory}/config/nvim/";
        recursive = true;
      };
    };
  };
}
