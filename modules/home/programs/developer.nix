{
  pkgs,
  lib,
  config,
  git,
  ...
}:

let
  fallbackProfileName = git.fallback;
  profileNames = builtins.attrNames git.profiles;
  dirsOf =
    profile:
    let
      d = git.profiles.${profile}.dirs or [ "${config.home.homeDirectory}/git/github.com/${profile}" ];
    in
    if builtins.isList d then d else [ d ];

  ensureGlob = dir: if lib.hasSuffix "/**" dir then dir else "${dir}/**";

  generateSshMatchblocks =
    profileNames:
    builtins.listToAttrs (
      builtins.map (profileName: {
        name = "github.com-${profileName}";
        value = {
          hostname = "github.com";
          user = "git";
          identityFile = "${config.sops.secrets."ssh/${profileName}/private".path}";
          identitiesOnly = true;
          forwardAgent = true;
          addKeysToAgent = "yes";
        };
      }) profileNames
    );

  generateGitIncludes =
    profileNames:
    builtins.concatMap (
      profileName:
      builtins.map (dir: {
        condition = "gitdir:${ensureGlob dir}";
        path = "${config.sops.templates."gitprofile-${profileName}".path}";
      }) (dirsOf profileName)
    ) profileNames;
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
      neovide
      nil # nix
      # languages
      go
      rustup
      coursier
      nodejs_24
      python312
      # doc
      pandoc
      # github cli
      gh
      # devenv
      devenv
      # duckdb
      duckdb
      # used to notify of theme changes
      dark-mode-notify
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
          # none!
        };
      };
    };

    # SSH configuration using git profiles
    programs.ssh = {
      enable = true;
      enableDefaultConfig = false;

      matchBlocks = generateSshMatchblocks profileNames;
    };

    # every programmers best friend
    programs.git = {
      enable = true;
      package = pkgs.gitFull;
      ignores = [ "*.swp" ];
      includes =
        (
          if fallbackProfileName != null && fallbackProfileName != "" then
            [ { path = config.sops.templates."gitprofile-${fallbackProfileName}".path; } ]
          else
            [ ]
        )
        ++ generateGitIncludes profileNames;

      settings = {
        init.defaultBranch = "main";
        gpg.format = "ssh";
        core = {
          editor = "vim";
          autocrlf = "input";
        };
        user = {
          useConfigOnly = true;
        };
        pull.rebase = true;
        push = {
          default = "current";
          autoSetupRemote = true;
        };
        rebase.autoStash = true;
        branch.sort = "-committerdate";
      };
    };
  };
}
