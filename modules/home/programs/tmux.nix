{
  pkgs,
  lib,
  config,
  self,
  ...
}:

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
          sesh list --icons | fzf-tmux -p 80%,70% \
            --no-sort --ansi --border-label ' sesh ' --prompt '⚡  ' \
            --header '  ^a all ^t tmux ^g github ^c configs ^x zoxide ^d tmux kill ^f find' \
            --bind 'tab:down,btab:up' \
            --bind 'ctrl-a:change-prompt(⚡  )+reload(sesh list --icons)' \
            --bind 'ctrl-t:change-prompt(🪟  )+reload(sesh list -t --icons)' \
            --bind 'ctrl-g:change-prompt(🐙  )+reload(sesh list -g --icons)' \
            --bind 'ctrl-c:change-prompt(⚙️  )+reload(sesh list -c --icons)' \
            --bind 'ctrl-x:change-prompt(📁  )+reload(sesh list -z --icons)' \
            --bind 'ctrl-f:change-prompt(🔎  )+reload(fd -H -d 2 -t d -E .Trash . ~)' \
            --bind 'ctrl-d:execute(tmux kill-session -t {2..})+change-prompt(⚡  )+reload(sesh list --icons)' \
            --preview-window 'right:55%' \
            --preview 'sesh preview {}'
        )\""

        bind-key "K" display-popup -E -w 80% "sesh connect \"$(
          sesh list -i | gum filter --limit 1 --placeholder 'Pick a sesh' --height 50 --prompt='⚡'
        )\""

        bind-key "G" display-popup -E -w 80% "sesh connect \"$(
          sesh list -g | gum filter --limit 1 --placeholder 'Pick a repo' --height 50 --prompt='⚡'
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
      #sesh
    ];

    home.shellAliases = {
      t = "sesh connect $(sesh list | fzf)";
      k = "sesh list -i | gum filter --limit 1 --placeholder 'Pick a sesh' --height 50 --prompt='⚡'";
    };

    home.file.".config/sesh/sesh.toml".source = "${self}/config/sesh/sesh.toml";
    home.file.".config/sesh/scripts/startup.sh" = {
      source = "${self}/config/sesh/scripts/startup.sh";
      executable = true;
    };
  };
}
