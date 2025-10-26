{
  self,
  inputs,
  pkgs,
  lib,
  config,
  enableLunar,
  nixDirectory,
  ...
}:

{
  options = {
    zsh.enable = lib.mkEnableOption "enables zsh";
  };

  config = lib.mkIf config.zsh.enable {
    home.packages = with pkgs; [
      jq
      yq
      gum
    ];

    programs.zsh = {
      enable = true;

      autocd = true;
      enableCompletion = true;
      autosuggestion.enable = true;
      syntaxHighlighting.enable = true;
      defaultKeymap = "viins";

      # NOTE: use-this for debugging performance issues
      # zprof.enable = true;

      plugins = [
        {
          name = "zshdefer";
          src = pkgs.zsh-defer;
          file = "share/zsh-defer/zsh-defer.zsh";
        }
        {
          name = "lunar";
          src = "${pkgs.lunar-zsh-plugin}/share/zsh/plugins/lunar-zsh-plugin/";
          file = "lunar.plugin.zsh";
        }
        # NOTE: temporary
        {
          name = "lw-zsh-aws";
          src = "${self}/scripts/lw-zsh/aws/";
          file = "aws.zsh";
        }
        {
          name = "lw-k8s-login";
          src = "${self}/scripts/lw-zsh/k8s-login/";
          file = "k8s-login.zsh";
        }
        {
          name = "lw-db";
          src = "${self}/scripts/lw-zsh/lw-db/";
          file = "lw-db.zsh";
        }
        {
          name = "admin_db";
          src = "${self}/scripts/lw-zsh/admin_db/";
          file = "admin_db.zsh";
        }
      ];

      shellAliases = {
        la = "ls -la";
        ll = "ls -l";
        nu = "pushd ${nixDirectory} && nix flake update && popd";
        ns = "pushd ${nixDirectory} && sudo darwin-rebuild --flake .#aarch64-darwin && popd";
        gn = "gitnow";
        "docker-compose" = "docker compose";
        hubble = "aws_wrapper hubble";
        k9s = "k8s_wrapper k9s";
        kubectl = "k8s_wrapper kubectl";
        schema = "async-schema-tooling";
        ast = "async-schema-tooling";
      };

      history.size = 10000;
      history.path = "${config.xdg.dataHome}/zsh/history";

      # NOTE: 500: early init, 550: before comp, 1000: general, 1500: last
      initContent =
        let
          zshConfigEarlyInit = lib.mkOrder 500 ''
            # Early NIX config
          '';

          zshConfig = lib.mkOrder 1000 ''
            # General NIX config
            if [[ -f /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh ]]; then
              . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
              . /nix/var/nix/profiles/default/etc/profile.d/nix.sh
            fi

            if [[ $(uname -m) == 'arm64' ]]; then
                eval "$(/opt/homebrew/bin/brew shellenv)"
            fi

            # refresh $GITHUB_ACCESS_TOKEN if unset
            if [[ $GITHUB_ACCESS_TOKEN == "" ]]; then
              export GITHUB_ACCESS_TOKEN=$(gh auth token);
            fi

            if [[ $GITHUB_TOKEN == "" ]]; then
              export GITHUB_TOKEN=$(gh auth token);
            fi

            if [[ -z $SSH_AUTH_SOCK ]] || ! kill -0 $SSH_AGENT_PID 2>/dev/null; then
              eval "$(ssh-agent -s)" >/dev/null
            fi

            export PATH="$HOME/.local/bin:$PATH"
          '';
        in
        lib.mkMerge [
          zshConfigEarlyInit
          zshConfig
        ];
    };

    programs.zoxide = {
      enable = true;
      enableZshIntegration = true;
    };

    programs.fzf = {
      enable = true;
      enableZshIntegration = true;
    };

    programs.starship = {
      enable = true;
      enableZshIntegration = true;
    };

    # NOTE: legacy shim for old lw-zsh plugins; remove when replacement tooling reaches full parity
    home.file.".zplug/repos/lunarway/lw-zsh/".source = "${self}/scripts/lw-zsh/";

    home.file.".aws/config".source = "${pkgs.lunar-zsh-plugin}/.aws/config";
    xdg.configFile = {
      "starship.toml" = {
        source = config.lib.file.mkOutOfStoreSymlink "${nixDirectory}/config/starship/rose-pine.toml";
      };
    };
  };
}
