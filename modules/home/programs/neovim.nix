{ inputs, pkgs, lib, config, ... }:

{
  options = {
    neovim.enable = lib.mkEnableOption "enables neovim";
  };

  config = lib.mkIf config.neovim.enable {
    programs.neovim = {
      enable = true;
      package = pkgs.neovim-unwrapped;
      #package = inputs.neovim-nightly-overlay.packages.${pkgs.system}.default;
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
        # mason requirements
        opam
        ocamlPackages.ocaml-lsp
        gopls
        delve
        gotools
        gofumpt
        tree-sitter
        nixfmt
        nil
        # langs
        ocaml
        go_1_23
        ruby_3_4
        nodejs_20
        lua5_1
        # utils
        pngpaste
        imagemagick
        mermaid-cli
      ];
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

