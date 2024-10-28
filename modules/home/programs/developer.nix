
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
      envsubst # cli env var substitution

      # languages
      go
      rustup

      # doc
      pandoc

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
        #settings = {
        #  pipx_uvx = true;
        #};

        tools = {
          python = "3.12.5";
          node = "22.7.0";
          go = "prefix:1.23";
          java = "zulu-21.36.17";
          dotnet = "8.0.401";
          perl = "5.40.0";
          lua = "5.4.7";
          gradle = "8.9";
          sbt = "1.10.1";
          uv = "0.4.17";
          "cargo:arroyo" = "latest";
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
    };
  };
}

