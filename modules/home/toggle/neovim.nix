{ inputs, pkgs, lib, config, ... }:

{
  options = {
    neovim.enable = lib.mkEnableOption "enables neovim";
  };

  config = lib.mkIf config.neovim.enable {
    programs.neovim = {
      enable = true;
      # package = pkgs.neovim;
      package = inputs.neovim-nightly-overlay.packages.${pkgs.system}.default;
      viAlias = true;
      vimAlias = true;
      defaultEditor = true;
      
      # additional
      vimdiffAlias = true;
      withNodeJs = true;
      withPython3 = true;
    };

    home.shellAliases = {
      lv = "nvim";
    };

    xdg.configFile = {
      "nvim" = {
        source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nixfiles-v2/config/nvim/.config/nvim";
        recursive = true;
      };
    };
  };
}

