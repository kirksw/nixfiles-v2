{
  pkgs,
  self,
  ...
}:

let
  user = "kirk";
in
{
  imports = [
    ./hardware-configuration.nix
    ../../../modules/shared
    ../../../modules/nixos
  ];

  nvidia.enable = true;
  
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


































































































































































































































































}
