{ pkgs, lib, config, ... }:

{
  options = {
    tmux.enable = lib.mkEnableOption "enables tmux";
  };

  config = lib.mkIf config.tmux.enable {
    programs.tmux = {
      enable = true;

      shell = "${pkgs.zsh}/bin/zsh";
      terminal = "screen-256color";
      prefix = "C-a";
      keyMode = "vi";
      mouse = true;
      baseIndex = 1;

      resizeAmount = 5;
      disableConfirmationPrompt = true;
      focusEvents = true;
      escapeTime = 10;
      clock24 = true;

      plugins = with pkgs; [
        tmuxPlugins.vim-tmux-navigator
        tmuxPlugins.tmux-fzf
        tmuxPlugins.catppuccin
        tmuxPlugins.tmux-floax
        tmuxPlugins.better-mouse-mode
        tmuxPlugins.battery
        tmuxPlugins.cpu
        #tmuxPlugins.vim-tmux-focus-events
        #tmuxPlugins.nord
      ];

      extraConfig = ''
        # misc
        set-option -g status-style bg=default
        set -g @catppuccin_flavor "mocha"
        set -g @catppuccin_window_status_style "basic"

        # combining tmux and nvim status lines
        set -g focus-events on
        set -g status-style bg=default
        # set -g status-left-length 90
        # set -g status-right-length 90
        # set -g status-justify absolute-centre

        # pane management binds
        unbind %
        bind | split-window -h
        unbind '"'
        bind - split-window -v
        #
        # keybinds for pane resizing
        bind -r j resize-pane -D 5
        bind -r k resize-pane -U 5
        bind -r l resize-pane -R 5
        bind -r h resize-pane -L 5
        bind -r m resize-pane -Z

        # copy mode binds
        bind -T copy-mode-vi v send-keys -X begin-selection # start selection with "v"
        bind -T copy-mode-vi y send-keys -X copy-selection  # copy text with "y"
        unbind -T copy-mode-vi MouseDragEnd2Pane

        # session management binds
        bind-key "T" run-shell "sesh connect \"$(
          sesh list | fzf-tmux -p 55%,60% \
            --no-sort --border-label ' sesh ' --prompt '⚡  ' \
            --header '  ^a all ^t tmux ^c configs ^g gitnow ^x zoxide ^d tmux kill ^f find' \
            --bind 'tab:down,btab:up' \
            --bind 'ctrl-a:change-prompt(⚡  )+reload(sesh list)' \
            --bind 'ctrl-t:change-prompt(🪟  )+reload(sesh list -t)' \
            --bind 'ctrl-c:change-prompt(⚙️  )+reload(sesh list -c)' \
            --bind 'ctrl-g:change-prompt(🔀  )+reload(gitnow)' \
            --bind 'ctrl-x:change-prompt(📁  )+reload(sesh list -z)' \
            --bind 'ctrl-f:change-prompt(🔎  )+reload(fd -H -d 2 -t d -E .Trash . ~)' \
            --bind 'ctrl-d:execute(tmux kill-session -t {})+change-prompt(⚡  )+reload(sesh list)'
        )\""
        
        bind-key "K" display-popup -E -w 40% "sesh connect \"$(
          sesh list -i | gum filter --limit 1 --placeholder 'Pick a sesh' --height 50 --prompt='⚡'
        )\""

        # clear screen
        bind C-l send-keys 'C-l'

        # settings for sesh 
        set -g default-terminal "screen-256color"
        set -ag terminal-overrides ",xterm-256color:RGB"
        set -g allow-passthrough on
        set -g detach-on-destroy off  

        # reload config
        bind r source-file ~/.config/tmux/tmux.conf \; display-message "Config reloaded..."
      '';
    };
    # add sesh for tmux session management
    home.packages = with pkgs; [
      sesh
    ];

    home.shellAliases = {
      t = "sesh connect $(sesh list | fzf)";
      k = "sesh list -i | gum filter --limit 1 --placeholder 'Pick a sesh' --height 50 --prompt='⚡'";
    };

    home.file.".config/sesh/sesh.toml" = {
        source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nixfiles-v2/config/sesh/sesh.toml";
    };
  
    home.file.".config/sesh/scripts/startup.sh" = {
        source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nixfiles-v2/config/sesh/scripts/startup.sh";
    };
  };
}

