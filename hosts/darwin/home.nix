{ config, pkgs, lib, ... }:

{
  home.stateVersion = "24.05";
  programs.home-manager.enable = true;

  home.packages = with pkgs; [
    # ideally move to packages
    neofetch
    hugo
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

  # disabled custom modules
  homerow.enable = false;
  wezterm.enable = false;
  gcloud.enable = false;
  vscode.enable = false;
  gowish.enable = false;
}
