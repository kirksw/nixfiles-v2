{ config, pkgs, ... }:
{
    # fonts
    fonts.packages = with pkgs; [
        nerd-fonts.fira-code
    ];

    fonts.fontconfig = {
        defaultFonts = {
            monospace = [ "Fira Code" ];
            sansSerif = [ "Fira Code" ];
            serif = [ "Fira Code" ];
            emoji = [ "Blobmoji" ];
        };
    };
  
    # sound
    security.rtkit.enable = true;
    services.pulseaudio.enable = false;
    services.pipewire = {
        enable = true;
        alsa = {
            enable = true;
            support32Bit = true;
        };
        pulse.enable = true;
    };

    # window manager
    services = {
        libinput.enable = true;

        xserver = {
            xkb.layout = "gb";
            windowManager = {
                awesome = {
                    enable = true;
                };
                i3 = {
                    enable = true;
                    package = pkgs.i3-gaps;
                };
                berry.enable = true;
                herbstluftwm.enable = true;
            };
        };

        displayManager.gdm = {
            enable = true;
            wayland = true;
        };
    };

    programs.sway = {
        enable = true;
        wrapperFeatures.gtk = true;
    };

    programs.slock.enable = true;
}