
{ pkgs, lib, config, ... }:

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
      autosuggestion.enable = true; 
      enableCompletion = true;
      plugins = [
        {
          name = "powerlevel10k";
          src = pkgs.zsh-powerlevel10k;
          file = "share/zsh-powerlevel10k/powerlevel10k.zsh-theme";
        }
      ];

      oh-my-zsh = {
        enable = true;
        plugins = [
          "docker"
          "git"
          "npm"
          "history"
          "node"
          "rust"
          "python"
          "deno"
          "kubectl"
        ];
      };

      shellAliases = {
        ll = "ls -l";
        build-switch = "cd ~/nixfiles-v2 && nix run build-switch";
        flake-update = "cd ~/nixfiles-v2 && nix flake update";
      };

      history.size = 10000;
      history.path = "${config.xdg.dataHome}/zsh/history";

      initExtra = ''
        if [[ -f /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh ]]; then
          . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
          . /nix/var/nix/profiles/default/etc/profile.d/nix.sh
        fi

        [[ ! -f ~/nixfiles-v2/config/zsh/.p10k.zsh ]] || source ~/nixfiles-v2/config/zsh/.p10k.zsh

        if [[ $(uname -m) == 'arm64' ]]; then
            eval "$(/opt/homebrew/bin/brew shellenv)"
        fi

        # k8s plugin manager
        [[ -f $(which krew) ]] || export PATH="$HOME/.krew/bin:$PATH"

        # if idea is installed, add it to the path
        if [[ -f "/Applications/IntelliJ IDEA.app/Contents/MacOS/idea" ]]; then
          export PATH="$PATH:/Applications/IntelliJ IDEA.app/Contents/MacOS"
        fi
      '';
    };

    programs.zoxide = {
      enable = true;
      enableZshIntegration = true;
    };

    programs.fzf = {
      enable = true;
      enableZshIntegration = true;
    };

    #xdg.configFile = {
    #  "mise" = {
    #    source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nixfiles-v2/config/general/mise";  
    #    recursive = true;
    #  };
    #};

    #xdg.configFile = {
    #  "scripts" = {
    #    source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nixfiles-v2/scripts";  
    #    recursive = true;
    #  };
    #}; 
  };
}
