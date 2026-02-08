{
  self,
  user,
  pkgs,
  ...
}:

{
  home = {
    stateVersion = "24.05";
    packages = with pkgs; [
      neofetch
      nerd-fonts.fira-code
      nerd-fonts.fira-mono
    ];
    sessionVariables = {
      LANG = "en_US.UTF-8";
      LC_ALL = "";
    };
  };

  programs.home-manager.enable = true;

  # enabled custom modules
  # security
  sops.enable = true;
  # dev tooling
  zsh.enable = true;
  developer.enable = true;
  colima.enable = true;
  devops.enable = true;
  # company
  lunar.enable = true;
  # editors
  neovim.enable = true;
  # multiplexer
  tmux.enable = true;
  zellij.enable = false;
  # terminal
  ghostty.enable = false;
  wezterm.enable = true;
  qemu.enable = true;
  # ai tooling
  aidev.enable = true;
  treekanga.enable = true;
  opencode.enable = true;
  codex.enable = true;
  swe-pruner-mcp.enable = false;
  # misc
  youtube.enable = true;

  # disabled custom modules
  communication.enable = false;
  homerow.enable = false;
  gcloud.enable = false;
  vscode.enable = false;
}
