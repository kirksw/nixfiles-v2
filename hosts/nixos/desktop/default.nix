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

  # system
  system.stateVersion = "25.11";

  # user
  users.users.${user} = {
    isNormalUser = true;
    home = "/home/${user}";
    description = "Kirk";
    extraGroups = [
      "wheel"
      "docker"
      "networkmanager"
    ];
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

  # $ nix search wget
  environment = {
    systemPackages = with pkgs; [
        wget
        htop
        wezterm
    ];
  };
}