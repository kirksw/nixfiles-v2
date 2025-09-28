{ pkgs, lib, config, ... }:

{
    options = {
        module.nvidia.enable = lib.mkEnableOption "enables nvidia packages";
    };

    config = lib.mkIf config.module.nvidia.enable {
        # enable opengl
        hardware.graphics = {
            enable = true;
        };

        # load nvidia driver for xorg and wayland
        services.xserver.videoDrivers = [ "nvidia" ];

        hardware.nvidia = {
            modesetting.enable = true;
            powerManagement.enable = true;
            powerManagement.finegrained = false;
            open = true;
            nvidiaSettings = true;

            package = config.boot.kernelPackages.nvidiaPackages.stable;
        };
    };
}