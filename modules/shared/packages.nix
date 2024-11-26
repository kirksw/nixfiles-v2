{ pkgs }:

with pkgs; [
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

  # ai
  # ollama (outdated)
  llama-cpp

  # credential
  docker-credential-helpers

  # ???
  # vscode
  # kcat
]
