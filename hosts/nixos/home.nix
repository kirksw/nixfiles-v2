{ config, pkgs, lib, ... }:

let
  user = "kirk";
  xdg_configHome  = "/home/${user}/.config";
in
{
  home = {
    enableNixpkgsReleaseCheck = false;
    username = "${user}";
    homeDirectory = "/home/${user}";
{ config, pkgs, lib, ... }:

{
  programs.home-manager.enable = true;
  home.stateVersion = "24.05";
  home.packages = with pkgs; [
    # ideally move to packages
    neofetch
    hugo
  ];

  # modules here
}