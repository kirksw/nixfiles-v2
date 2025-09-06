{
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
  ];

  home.sessionVariables = {
    LANG = "en_US.UTF-8";
    LC_ALL = "";
  };

  # enabled custom modules
  zsh.enable = true;
  neovim.enable = true;
  developer.enable = true;
  tmux.enable = true;
  colima.enable = true;
  devops.enable = true;
  youtube.enable = true;
  zellij.enable = true;
  lunar.enable = true;
  ghostty.enable = true; # NOTE: only used for config (install via homebrew)
  qemu.enable = true;

  # disabled custom modules
  communication.enable = false;
  homerow.enable = false;
  wezterm.enable = false;
  gcloud.enable = false;
  vscode.enable = false;
}
