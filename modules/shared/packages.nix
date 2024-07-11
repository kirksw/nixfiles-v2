{ pkgs }:

with pkgs; [
  # General packages for development and system management
  bat
  btop
  coreutils
  killall
  # neofetch
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
  yq
  jq
  ripgrep
  tree
  unrar
  unzip

  # Python packages
  python311
  python311Packages.virtualenv # globally install virtualenv
]
