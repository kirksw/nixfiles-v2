{
  pkgs,
  lib,
  config,
  nixDirectory,
  ...
}:

{
  options = {
    neovim.enable = lib.mkEnableOption "enables neovim";
  };

  config = lib.mkIf config.neovim.enable {
    programs.neovim = {
      enable = true;
      package = pkgs.neovim-unwrapped;
      viAlias = true;
      vimAlias = true;
      defaultEditor = true;
      vimdiffAlias = true;
      withRuby = false;
      withNodeJs = false;
      withPython3 = false;

      plugins = with pkgs; [
        vimPlugins.nvim-treesitter.withAllGrammars
      ];

      extraPackages = with pkgs; [
        tree-sitter
        helm-ls
        statix
        nil
        nixfmt
      ];

      #extraPackages = with pkgs; [
      #  # mason requirements
      #  gopls
      #  delve
      #  gotools
      #  gofumpt
      #  tree-sitter
      #  nixfmt
      #  nil
      #  # langs
      #  ocaml
      #  go_1_25
      #  ruby_3_4
      #  nodejs_20
      #  lua5_1
      #  # utils
      #  pngpaste
      #  imagemagick
      #  mermaid-cli
      #];
    };

    home.shellAliases = {
      lv = "nvim";
    };

    xdg.configFile = {
      "nvim" = {
        source = config.lib.file.mkOutOfStoreSymlink "${nixDirectory}/config/nvim/";
        recursive = true;
      };
    };
  };
}
