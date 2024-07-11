{ config, pkgs, lib, ... }:

{
  home.stateVersion = "24.05";
  programs.home-manager.enable = true;

  home.packages = with pkgs; [
    neofetch
  ];

  # enabled custom modules
  zsh.enable = true;
  neovim.enable = true;
  developer.enable = true;
  tmux.enable = true;
  cloud.enable = true;
  colima.enable = true;
  devops.enable = true;
  wezterm.enable = true;
  youtube.enable = true;

  # disabled custom modules
  zellij.enable = false;
  vscode.enable = false;
}
