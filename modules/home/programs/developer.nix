{
  pkgs,
  lib,
  config,
  ...
}:

let
  name = "Kirk Sweeney";
  email = "kirk@cntd.io";
  homeDir = "/Users/${config.home.username}";
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
      fd # user friendly alternative to find

      # languages
      go
      rustup
      coursier

      # doc
      pandoc

      # github cli
      gh

      # devenv
      devenv

      # nix
      nil

      # duckdb
      duckdb

      # misc
      marp-cli
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
          idiomatic_version_file_enable_tools = [ ];
        };

        tools = {
          uv = "0.7";
          python = "3.13";
          java = "adoptopenjdk-21";
          scala = "3.7";
          node = "latest";
          "cargo:arroyo" = "latest";
          "cargo:bacon" = "latest";
        };
      };
    };

    # every programmers best friend
    programs.git = {
      enable = true;
      ignores = [ "*.swp" ];
      userName = name;
      userEmail = email;
      signing = {
        key = "1AFA8CEF192E7481";
        signByDefault = true;
      };
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
          condition = "gitdir:${homeDir}/git/github.com/lunarway/**";
          path = "~/git/github.com/lunarway/.gitconfig-lunarway";
        }
        # example .gitconfig
        #
        # [user]
        # name = <name>
        # email = <email>
        # signingkey = <key>
        #
        # [core]
        #   sshCommand = ssh -i ~/.ssh/<private_key>
        #
        # [url "git@github.com:<org>/"]
        #   insteadOf = https://github.com/<org>/
      ];
    };
  };
}
