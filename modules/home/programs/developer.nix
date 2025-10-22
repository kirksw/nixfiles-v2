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
  keyOf = profile: (git.profiles.${profile}.sshKey or "default");
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
          identityFile = "${config.sops.secrets."ssh/${keyOf profileName}/private".path}";
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
      #// {
      #  "*.ts.net" = {
      #    hostname = "github.com";
      #    user = "git";
      #    identityFile = config.sops.secrets."ssh/${keyOf fallbackProfileName}/private".path;
      #    identitiesOnly = true;
      #    forwardAgent = true;
      #    addKeysToAgent = "yes";
      #  };
      #  "*" = {
      #    hostname = "github.com";
      #    user = "git";
      #    identityFile = config.sops.secrets."ssh/${keyOf fallbackProfileName}/private".path;
      #    identitiesOnly = true;
      #    forwardAgent = true;
      #    addKeysToAgent = "yes";
      #  };
      #};
    };

    # every programmers best friend
    programs.git = {
      enable = true;
      ignores = [ "*.swp" ];
      includes = [
        { path = config.sops.templates."gitprofile-${fallbackProfileName}".path; }
      ]
      ++ generateGitIncludes profileNames;

      settings = {
        init.defaultBranch = "main";
        gpg.format = "ssh";
        core = {
          editor = "vim";
          autocrlf = "input";
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
