
{ pkgs, lib, config, ... }:

{
  options = {
    vscode.enable = lib.mkEnableOption "enables vscode";
  };

  config = lib.mkIf config.vscode.enable {
    programs.vscode = {
      enable = true;
      profiles.default.extensions = with pkgs.vscode-extensions; [
          vscodevim.vim
          ms-vscode-remote.remote-containers
          jnoortheen.nix-ide
      ];
    };
  };
}
