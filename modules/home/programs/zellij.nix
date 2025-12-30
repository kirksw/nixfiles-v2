{
  lib,
  config,
  ...
}:

{
  options = {
    zellij.enable = lib.mkEnableOption "enables zellij";
  };

  config = lib.mkIf config.zellij.enable {
    programs.zellij = {
      enable = true;
      enableZshIntegration = false;
      attachExistingSession = false;
      exitShellOnExit = false;
      settings = {
        pane_frames = false;
        tab_bar = false;
        default_layout = "compact";
        theme = "ayu_dark";
        default_shell = "zsh";
        ui = {
          pane_frames = {
            hide_session_name = true;
          };
        };
        show_startup_tips = false;
        show_release_notes = false;
      };

      extraConfig = ''
        keybinds {
          shared_except "locked" {
            bind "Ctrl h" {
              MessagePlugin "https://github.com/hiasr/vim-zellij-navigator/releases/download/0.3.0/vim-zellij-navigator.wasm" {
                name "move_focus_or_tab";
                payload "left";
                move_mod "ctrl";
                use_arrow_keys "false";
              };
            }

            bind "Ctrl j" {
              MessagePlugin "https://github.com/hiasr/vim-zellij-navigator/releases/download/0.3.0/vim-zellij-navigator.wasm" {
                name "move_focus";
                payload "down";
                move_mod "ctrl";
                use_arrow_keys "false";
              };
            }

            bind "Ctrl k" {
              MessagePlugin "https://github.com/hiasr/vim-zellij-navigator/releases/download/0.3.0/vim-zellij-navigator.wasm" {
                name "move_focus";
                payload "up";
                move_mod "ctrl";
                use_arrow_keys "false";
              };
            }

            bind "Ctrl l" {
              MessagePlugin "https://github.com/hiasr/vim-zellij-navigator/releases/download/0.3.0/vim-zellij-navigator.wasm" {
                name "move_focus_or_tab";
                payload "right";
                move_mod "ctrl";
                use_arrow_keys "false";
              };
            }
          }
        }
      '';
    };
  };
}
