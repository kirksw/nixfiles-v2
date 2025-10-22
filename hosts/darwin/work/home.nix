{
  self,
  user,
  pkgs,
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

  home.sessionVariables = {
    LANG = "en_US.UTF-8";
    LC_ALL = "";
  };

  # enabled custom modules
  #sketchybar.enable = true;
  sops.enable = true;
  zsh.enable = true;
  neovim.enable = true;
  developer.enable = true;
  tmux.enable = true;
  colima.enable = true;
  devops.enable = true;
  youtube.enable = true;
  zellij.enable = true;
  lunar.enable = true;
  ghostty.enable = true;
  wezterm.enable = true;
  qemu.enable = true;

  # disabled custom modules
  communication.enable = false;
  homerow.enable = false;
  gcloud.enable = false;
  vscode.enable = false;
}
