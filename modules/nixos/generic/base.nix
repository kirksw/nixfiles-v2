{ config, pkgs, ... }:
{
    # fonts
    fonts.fonts = with pkgs; [
        cascadia-code
        ibm-plex
        (nerdfonts.override { fonts = [ "CascadiaCode" "FiraCode" "Iosevka" "JetBrainsMono" ]; })
        noto-fonts-emoji-blob-bin
    ];

    fonts.fontconfig = {
        defaultFonts = {
        monospace = [ "Cascadia Code" ];
        sansSerif = [ "Cascadia Code" ];
        serif = [ "Cascadia Code" ];
        emoji = [ "Blobmoji" ];
        };
    };
  
    # sound
    sound.enable = false;
    hardware.pulseaudio.enable = false;
    security.rtkit.enable = true;
    services.pipewire = {
        enable = true;
        alsa = {
        enable = true;
        support32Bit = true;
        };
        pulse.enable = true;
    };

    # window manager
    services.xserver = {
        enable = true;
        # displayManager.lightdm = {
        #   enable = true;
        #   greeters.gtk.enable = true;
        # };
        displayManager.gdm = {
        enable = true;
        wayland = true;
        };
        libinput.enable = true;
        layout = "gb";
        windowManager = {
        awesome = {
            enable = true;
            package = pkgs.awesome-git;
        };
        i3 = {
            enable = true;
            package = pkgs.i3-gaps;
        };
        berry.enable = true;
        herbstluftwm.enable = true;
        };
    };
    programs.sway = {
        enable = true;
        wrapperFeatures.gtk = true;
    };

    programs.slock.enable = true;
}