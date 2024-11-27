{ config, lib, pkgs, modulesPath, ... }:

{
  imports =
    [ (modulesPath + "/installer/scan/not-detected.nix")
    ];

  fileSystems."/" =
    { device = "/dev/disk/by-uuid/e13c1350-f9c7-419f-9935-aab1e454f172";
      fsType = "ext4";
    };

  fileSystems."/boot" =
    { device = "/dev/disk/by-uuid/CF9B-5E72";
      fsType = "vfat";
    };

  swapDevices = [ ];
}
