{ pkgs, lib, config, unstable, ... }:

{
  options = {
    tmux.enable = lib.mkEnableOption "enables tmux";
  };

  config = lib.mkIf config.tmux.enable {
    programs.tmux = {
      enable = true;

      extraConfig = ''
        # Don't exit from tmux on closing a session
        set -g detach-on-destroy off  
        set -ga terminal-overrides ",xterm-256color*:Tc"

        # fix errors relating to vim
        set-option -g focus-events on
        set-option -sg escape-time 10

        # Set tmux bind to Ctrl+a instead of default Ctrl+b
        unbind C-b
        set-option -g prefix C-a
        bind-key C-a send-prefix

        # I like clear screen as ctrl+l
        bind C-l send-keys 'C-l'
        
        # remove kill-pane prompt 
        bind-key x kill-pane 
        
        # Change keybinds for splits
        unbind %
        bind | split-window -h
      
        unbind '"'
        bind - split-window -v
        
        # Keybind for refreshing config
        bind r source-file ~/.tmux.conf
        set -g base-index 1
        
        # Keybinds for pane resizing
        bind -r j resize-pane -D 5
        bind -r k resize-pane -U 5
        bind -r l resize-pane -R 5
        bind -r h resize-pane -L 5
        
        # Keybind for maximize/minimize
        bind -r m resize-pane -Z
        
        # Enable mouse
        set -g mouse on
        
        # Use vim movements for tmux copy mode
        set-window-option -g mode-keys vi
      
        bind -T copy-mode-vi v send-keys -X begin-selection # start selection with "v"
        bind -T copy-mode-vi y send-keys -X copy-selection  # copy text with "y"
      
        unbind -T copy-mode-vi MouseDragEnd1Pane
        
        # tmux plugins
        set -g @plugin 'tmux-plugins/tpm'
      
        set -g @plugin 'christoomey/vim-tmux-navigator' # navigate panes and vim with ctrl-hjkl
        set -g @plugin 'jimeh/tmux-themepack' # tmux theme
        set -g @themepack 'powerline/default/cyan' # use this theme for tmux
        
        # open todo notes
        bind -r D neww -c "#{pane_current_path}" "[[ -e TODO.md ]] && nvim TODO.md || nvim ~/.dotfiles/personal/todo.md"
        
        # fix errors relating to vim
        set-option -sg escape-time 10
        set-option -g focus-events on
      
        if "test ! -d ~/.tmux/plugins/tpm" \
          "run 'git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm && ~/.tmux/plugins/tpm/bin/install_plugins'"

        bind-key "T" run-shell "sesh connect \"$(
          sesh list | fzf-tmux -p 55%,60% \
            --no-sort --border-label ' sesh ' --prompt '⚡  ' \
            --header '  ^a all ^t tmux ^g configs ^x zoxide ^d tmux kill ^f find' \
            --bind 'tab:down,btab:up' \
            --bind 'ctrl-a:change-prompt(⚡  )+reload(sesh list)' \
            --bind 'ctrl-t:change-prompt(🪟  )+reload(sesh list -t)' \
            --bind 'ctrl-g:change-prompt(⚙️  )+reload(sesh list -c)' \
            --bind 'ctrl-x:change-prompt(📁  )+reload(sesh list -z)' \
            --bind 'ctrl-f:change-prompt(🔎  )+reload(fd -H -d 2 -t d -E .Trash . ~)' \
            --bind 'ctrl-d:execute(tmux kill-session -t {})+change-prompt(⚡  )+reload(sesh list)'
        )\""
        
        bind-key "K" display-popup -E -w 40% "sesh connect \"$(
          sesh list -i | gum filter --limit 1 --placeholder 'Pick a sesh' --height 50 --prompt='⚡'
        )\""

        # Initialize TMUX plugin manager (keep this line at the very bottom of tmux.conf)
        run '~/.tmux/plugins/tpm/tpm'
      '';
    };

    # add sesh for tmux session management
    home.packages = with pkgs; [
      sesh
    ];

    home.shellAliases = {
      t = "sesh connect $(sesh list | fzf)";
    };

    home.file.".config/sesh/sesh.toml" = {
        source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nixfiles-v2/config/general/sesh/sesh.toml";
    };
  
    home.file.".config/sesh/scripts/startup.sh" = {
        source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nixfiles-v2/config/general/sesh/scripts/startup.sh";
    };
  };
}

