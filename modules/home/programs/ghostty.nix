{
  inputs,
  pkgs,
  pkgs-stable,
  lib,
  config,
  ...
}:

{
  options = {
    ghostty.enable = lib.mkEnableOption "enables ghostty";
  };

  config = lib.mkIf config.ghostty.enable {
    programs.ghostty = {
      enable = true;
      package = null; # package = inputs.ghostty.packages.${pkgs.system}.default;
      enableZshIntegration = true;
      #clearDefaultKeybinds = true;
      # NOTE: these can only be used on linux
      # installVimSyntax = true;
      # installBatSyntax = true;
      settings = {
        keybind = [
          "ctrl+comma=open_config"
          "ctrl+enter=toggle_fullscreen"
        ];
        theme = "light:rose-pine-dawn,dark:rose-pine";
        font-size = 14;
        font-family = "FiraCode Nerd Font Mono";
        font-thicken = true;
        font-style = "Regular";
        window-decoration = false;
        window-padding-x = 0;
        window-padding-y = 0;
        confirm-close-surface = false;
        cursor-style = "block";
        cursor-style-blink = false;
        unfocused-split-opacity = 0.6;
        background-opacity = 0.8;
        background-blur = true;
        background-blur-radius = 20;
        # font-feature = [ "-liga" "-dlig" "-calt" ];
      };
    };
  };
}
