
{ pkgs, lib, config, ... }:

let 
  name = "Kirk Sweeney";
  email = "kirk.sweeney@outlook.com"; 
in
{
  options = {
    developer.enable = lib.mkEnableOption "enables developer tools";
  };

  config = lib.mkIf config.developer.enable {
    # development tools
    home.packages = with pkgs; [
      # cli tools
      lazygit # tui git client
      pet # snippet manager
      yq # cli yaml processor
      jq # cli json processor
      curl # cli http client
      envsubst # cli env var substitution

      # languages
      go
      rustup
      coursier

      # doc
      pandoc

      # rest client
      bruno

      # github cli
      gh

      # devenv
      devenv

      # nix
      # nil
      
      # duckdb
      duckdb
    ];

    # direnv
    programs.direnv = {
      enable = true;
    };

    # tooling management
    programs.mise = {
      enable = true;
      enableZshIntegration = true;

      globalConfig = {
        settings = {
          pipx_uvx = true;
        };

        tools = {
          python = "3.13";
          node = "24";
          go = "prefix:1.24";
          java = "adoptopenjdk-21";
          dotnet = "9";
          perl = "5.40";
          lua = "5";
          gradle = "8";
          sbt = "1.10";
          uv = "0.7";
          scala = "3";
          "cargo:arroyo" = "latest";
          "cargo:bacon" = "latest";
          "cargo:gitnow" = "latest";
        };
      };
    };

    # every programmers best friend
    programs.git = {
      enable = true;
      ignores = ["*.swp"];
      userName = name;
      userEmail = email;
      lfs = {
        enable = true;
      };
      extraConfig = {
        init.defaultBranch = "main";
        core = {
        editor = "vim";
          autocrlf = "input";
        };
        pull.rebase = true;
        rebase.autoStash = true;
      };

      includes = [
        {
          condition = "gitdir:~/projects/work/";
          contents = {
            user = {
              name = name;
              email = "ks@onskeskyen.dk";
              signingKey = builtins.replaceStrings ["\n"] [""] (builtins.readFile ~/secrets/work.gpg);
            };

            commit = {
              gpgSign = true;
            };
          };
        }
      ];
    };
  };
}

