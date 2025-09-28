{ config, pkgs, ... }:

{ pkgs, lib, config, ... }:

{
    options = {
        module.nvidia.enable = lib.mkEnableOption "enables nvidia packages";
    };

    config = lib.mkIf config.module.nvidia.enable {
        services.xserver.videoDrivers = [ "nvidia" ];
        hardware = {
            opengl.enable = true;
            nvidia = {
                package = config.boot.kernelPackages.nvidiaPackages.stable;
                modesetting.enable = true;
                powerManagement.enable = true;
            };
        };
    };
}