{ pkgs, lib, config, ... }:

let
  repoRoot = ../../..;
in
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
      #dotDir = ".config/zsh";
      enableCompletion = true;
      autosuggestion.enable = true; 
      syntaxHighlighting.enable = true; 
      defaultKeymap = "viins";

      # NOTE: use-this for debugging performance issues 
      # zprof.enable = true;

      plugins = [
        {
          name = "powerlevel10k";
          src = pkgs.zsh-powerlevel10k;
          file = "share/zsh-powerlevel10k/powerlevel10k.zsh-theme";
        }
        {
          name = "zshdefer";
          src = pkgs.zsh-defer;
          file = "share/zsh-defer/zsh-defer.zsh";
        }
        {
          name = "lunar";
          src = "${repoRoot}/scripts/lunar";
          file = "lunar.plugin.zsh";
        }
      ];

      shellAliases = {
        la = "ls -la";
        ll = "ls -l";
        nu = "cd ~/nixfiles-v2 && nix flake update";
        #ns = "sudo nix run nix-darwin -- switch --flake ~/nixfiles-v2#aarch64-darwin --impure";
        gn = "gitnow";
        awsenv = "aws_fzf_profile";
        k8senv = "kubectl config use-context $(kubectl config get-contexts --no-headers | sed 's/^*//g' | awk '{print $1}' | fzf --prompt \"Choose k8s context: \")";
        "docker-compose" = "docker compose";
      };

      history.size = 10000;
      history.path = "${config.xdg.dataHome}/zsh/history";

      # NOTE: 500: early init, 550: before comp, 1000: general, 1500: last
      initContent = let
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

          # k8s plugin manager
          [[ -f $(which krew) ]] || export PATH="$HOME/.krew/bin:$PATH"

          # powerlevel10k
          [[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

          # shuttle
          [[ ! -f $(which shuttle) ]] || source <(shuttle completion zsh)

          # hamctl
          [[ ! -f $(which hamctl) ]] || source <(hamctl completion zsh)

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
        '';
      in
        lib.mkMerge [ zshConfigEarlyInit zshConfig ];
    };

    programs.zoxide = {
      enable = true;
      enableZshIntegration = true;
    };

    programs.fzf = {
      enable = true;
      enableZshIntegration = true;
    };

    home.file.".p10k.zsh".source = "${repoRoot}/config/zsh/p10k.zsh";
  };
}
