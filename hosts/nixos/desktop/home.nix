{
  pkgs,
  user,
  ...
}:

{
  home.stateVersion = "24.05";
  programs.home-manager.enable = true;

  home.packages = with pkgs; [
    neofetch
    hugo
    nerd-fonts.fira-code
    nerd-fonts.fira-mono
    sketchybar-app-font
  ];

  # enable home modules here
  sops.enable = true;
  zsh.enable = true;
  neovim.enable = true;
  developer.enable = true;
  tmux.enable = true;
  devops.enable = true;
  youtube.enable = true;
  zellij.enable = true;
  ghostty.enable = true;
  qemu.enable = true;

  # disabled custom modules
  colima.enable = false;
  communication.enable = false;
  homerow.enable = false;
  wezterm.enable = false;
  gcloud.enable = false;
  vscode.enable = false;
}
