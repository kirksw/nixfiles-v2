
{ inputs, pkgs, pkgs-stable, lib, config, ... }:

{
  options = {
    ghostty.enable = lib.mkEnableOption "enables ghostty";
  };

  config = lib.mkIf config.ghostty.enable {
    programs.ghostty = {
      enable = true;
      package = null; # package = inputs.ghostty.packages.${pkgs.system}.default;
      enableZshIntegration = true;
      # NOTE: these can only be used on linux
      # installVimSyntax = true;
      # installBatSyntax = true;
      settings = {
        keybind = [
          "ctrl+comma=open_config"
          # "ctrl+enter=toggle_fullscreen"
        ];
        font-size = 14;
        font-family = "Fira-Code-Mono Nerd Font";
        window-decoration = false;
        confirm-close-surface = false;
        cursor-style = "block";
        cursor-style-blink = false;

        unfocused-split-opacity = 0.9;
        background-opacity = 0.8;
        background-blur-radius = 20;

        window-theme = "dark";

        # Disables ligatures
        font-feature = [ "-liga" "-dlig" "-calt" ];
      };
    };
  };
}
