{
  pkgs,
  user,
  self,
  ...
}:

{
  imports = [
    ./hardware-configuration.nix
    ../../../modules/shared
    ../../../modules/nixos
  ];

  module.nvidia.enable = true;

  # baseline
  programs.zsh.enable = true;

  users.users.${user} = {
    isNormalUser = true;
    extraGroups = [ "wheel" "video" "audio" "camera" "networkmanager" "kvm" "libvirtd" "plex" ];
    shell = pkgs.zsh;
  };
  
  security.sudo.wheelNeedsPassword = false;

  # Set your time zone.
  time.timeZone = "Europe/Copenhagen";

  # Select internationalisation properties.
  i18n = {
    defaultLocale = "en_DK.UTF-8";

    extraLocaleSettings = {
      LC_ADDRESS = "da_DK.UTF-8";
      LC_IDENTIFICATION = "da_DK.UTF-8";
      LC_MEASUREMENT = "da_DK.UTF-8";
      LC_MONETARY = "da_DK.UTF-8";
      LC_NAME = "da_DK.UTF-8";
      LC_NUMERIC = "da_DK.UTF-8";
      LC_PAPER = "da_DK.UTF-8";
      LC_TELEPHONE = "da_DK.UTF-8";
      LC_TIME = "da_DK.UTF-8";
    };
  };

  console = {
    font = "Lat2-Terminus16";
    keyMap = "us";
  };

  environment = {
    variables = {
      TERMINAL = "wezterm";
      EDITOR = "nvim";
      VISUAL = "nvim";
    };

    systemPackages = with pkgs; [
      wget
      curl
      git
      wezterm
    ];
  };

  nix = {
    settings = {
      auto-optimise-store = true;
      experimental-features = [ "nix-command" "flakes" ];
    };
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 30d";
    };
    package = pkgs.nixVersions.stable;
    registry.nixpkgs.flake = pkgs;
    extraOptions = ''
      keep-outputs = true
      keep-derivations = true
    '';
  };

  nixpkgs.config.allowUnfree = true;
 
  system = {
    stateVersion = "23.05";
  };
  
  # other
  boot = {
    kernelPackages = pkgs.linuxPackages_latest;
    loader = {
        grub = {
            enable = true;
            useOSProber = true;
            device = "nodev";
        };

        efi.canTouchEfiVariables = true;
    };
  };
}