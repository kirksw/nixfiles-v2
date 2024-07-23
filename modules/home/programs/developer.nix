
{ pkgs, lib, config, ... }:

let name = "Kirk Sweeney";
    user = "kirk";
    email = "kirk.sweeney@outlook.com"; in
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

      # languages
      go
      rustup

      # rest client
      bruno

      # github cli
      gh
    ];

    # tooling management
    programs.mise = {
      enable = true;
      enableZshIntegration = true;

      globalConfig = {
        tools = {
          python = "3.10";
          node = "lts";
          go = "prefix:1.20";
          rust = "nightly";
          java = "zulu-17";
          dotnet = "7.0.201";
          perl = "latest";
          lua = "5.4";
          maven = "3.9";
          gradle = "8.7";
          sbt = "latest";
          "cargo:arroyo" = "latest";
        };
      };
    };

    # every programmers best friend
    programs.git = {
      enable = true;
      ignores = [ "*.swp" ];
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
    };
  };
}

