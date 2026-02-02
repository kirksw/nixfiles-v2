{
  pkgs,
  lib,
  config,
  ...
}:

{
  options = {
    module.baseline.enable = lib.mkEnableOption "enables baseline packages";
  };

  config = lib.mkIf config.module.baseline.enable {
    home.packages = with pkgs; [
      # General packages for development and system management
      bat
      btop
      coreutils
      killall
      openssh
      sqlite
      wget
      zip

      # Encryption and security tools
      age
      age-plugin-yubikey
      gnupg
      libfido2

      # Media-related packages
      ffmpeg
      fd

      # Text and terminal utilities
      htop
      ripgrep
      tree
      unrar
      unzip

      # proton
      proton-pass-cli

      # credential
      docker-credential-helpers

      # apps
      #discord
    ];
  };
}
