{ ... }:

{
  imports = [ 
    ./programs/baseline.nix
    ./programs/gcloud.nix
    ./programs/colima.nix
    ./programs/developer.nix
    ./programs/devops.nix
    ./programs/neovim.nix
    ./programs/tmux.nix
    ./programs/vscode.nix
    ./programs/wezterm.nix
    ./programs/youtube.nix
    ./programs/zellij.nix
    ./programs/zsh.nix
    ./programs/ghostty.nix
    ./services/homerow.nix
    ./programs/lunar.nix
  ];

  module.baseline.enable = true;
}
