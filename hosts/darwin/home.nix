{ config, pkgs, lib, ... }:

{
  home.stateVersion = "24.05";
  programs.home-manager.enable = true;

  home.packages = with pkgs; [
    # ideally move to packages
    neofetch
    hugo
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
  gowish.enable = true;
  homerow.enable = false;
  zellij.enable = false;
  vscode.enable = false;
}
