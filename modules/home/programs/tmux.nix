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
        tmuxPlugins.rose-pine
        tmuxPlugins.better-mouse-mode
        tmuxPlugins.battery
        tmuxPlugins.cpu
      ];

      extraConfig = ''
        set-option -g status-style bg=default
        set -g @rose_pine_variant 'main' # Options are 'main', 'moon' or 'dawn'

        set -g @rose_pine_host 'on'
        set -g @rose_pine_hostname_short 'on'
        #set -g @rose_pine_date_time 'yy-mm-dd HH:MM'
        set -g @rose_pine_user 'on'
        set -g @rose_pine_directory 'on' # Turn on the current folder component in the status bar
        set -g @rose_pine_bar_bg_disable 'on' # Disables background color, for transparent terminal emulators
        set -g @rose_pine_bar_bg_disabled_color_option 'default'

        set -g @rose_pine_only_windows 'on' # Leaves only the window module, for max focus and space
        set -g @rose_pine_disable_active_window_menu 'on' # Disables the menu that shows the active window on the left

        set -g @rose_pine_default_window_behavior 'on' # Forces tmux default window list behaviour
        set -g @rose_pine_show_current_program 'on' # Forces tmux to show the current running program as window name
        set -g @rose_pine_show_pane_directory 'on' # Forces tmux to show the current directory as window name
        # Previously set -g @rose_pine_window_tabs_enabled

        # Example values for these can be:
        set -g @rose_pine_left_separator ' > ' # The strings to use as separators are 1-space padded
        set -g @rose_pine_right_separator ' < ' # Accepts both normal chars & nerdfont icons
        set -g @rose_pine_field_separator ' | ' # Again, 1-space padding, it updates with prefix + I
        set -g @rose_pine_window_separator ' - ' # Replaces the default `:` between the window number and name

        # These are not padded
        set -g @rose_pine_session_icon '' # Changes the default icon to the left of the session name
        set -g @rose_pine_current_window_icon '' # Changes the default icon to the left of the active window name
        set -g @rose_pine_folder_icon '' # Changes the default icon to the left of the current directory folder
        set -g @rose_pine_username_icon '' # Changes the default icon to the right of the hostname
        set -g @rose_pine_hostname_icon '󰒋' # Changes the default icon to the right of the hostname
        set -g @rose_pine_date_time_icon '󰃰' # Changes the default icon to the right of the date module
        set -g @rose_pine_window_status_separator "  " # Changes the default icon that appears between window names

        # Very beta and specific opt-in settings, tested on v3.2a, look at issue #10
        set -g @rose_pine_prioritize_windows 'on' # Disables the right side functionality in a certain window count / terminal width
        set -g @rose_pine_width_to_hide '80' # Specify a terminal width to toggle off most of the right side functionality
        set -g @rose_pine_window_count '5' # Specify a number of windows, if there are more than the number, do the same as width_to_hide

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
