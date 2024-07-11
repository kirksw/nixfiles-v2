{ pkgs, lib, config, ... }:

{
  options = {
    youtube.enable = lib.mkEnableOption "enables module";
  };

  config = lib.mkIf config.youtube.enable {
    home.packages = with pkgs; [
      yt-dlp
      mpv
      # ytui_music
    ];
  };
}
