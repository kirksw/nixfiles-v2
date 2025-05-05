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
  gcloud.enable = true;
  colima.enable = true;
  devops.enable = true;
  wezterm.enable = false;
  youtube.enable = true;
  homerow.enable = false;
  zellij.enable = false;
  #vscode.enable = true;
  lunar.enable = true;
  ghostty.enable = true; # NOTE: only used for config (install via homebrew)

  # disabled custom modules
  #gowish.enable = false;
}
