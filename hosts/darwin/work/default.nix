{
  lib,
  pkgs,
  user,
  self,
  ...
}:

let
  nixConfFormat = pkgs.formats.nixConf {
    package = pkgs.nix;
    version = "2.31";
  };
in
{
  imports = [
    ../../../modules/shared
    ../../../modules/darwin
  ];

  # modules
  aerospace.enable = true;
  tailscale.enable = true;
  jankyborders.enable = true;

  # specific host config
  nixpkgs.config.allowUnfree = true;

  users.users.${user} = with pkgs; {
    home = "/Users/${user}";
    shell = zsh;
  };

  environment.shells = with pkgs; [
    zsh
  ];
  programs.zsh.enable = true;

  environment.variables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
    SOPS_AGE_KEY_FILE = "$HOME/.config/age/keys.txt";
  };

  ids.gids.nixbld = 350;

  nix.enable = false;

  environment.etc."nix/nix.custom.conf".text = pkgs.lib.mkForce ''
    trusted-users = kisw root
    extra-experimental-features = external-builders
    external-builders = [{"systems":["aarch64-linux","x86_64-linux"],"program":"/usr/local/bin/determinate-nixd","args":["builder"]}]
    eval-cores = 0
  '';

  security = {
    pam.services.sudo_local = {
      enable = true;
      reattach = true;
      touchIdAuth = true;
      watchIdAuth = true;
    };

    sudo = {
      extraConfig = ''
        Defaults  timestamp_timeout=5
      '';
    };
  };

  system = {
    stateVersion = 6;
    primaryUser = "${user}";
    checks.verifyNixPath = false;

    defaults = {
      NSGlobalDomain = {
        AppleInterfaceStyle = "Dark";
        AppleShowAllExtensions = true;
        ApplePressAndHoldEnabled = false;
        NSWindowShouldDragOnGesture = true;

        KeyRepeat = 1;
        InitialKeyRepeat = 15; # ~0,25 s

        # Automatically hide and show the menu bar if using sketchybar
        _HIHideMenuBar = false;

        "com.apple.mouse.tapBehavior" = 1;
        "com.apple.sound.beep.volume" = 0.0;
        "com.apple.sound.beep.feedback" = 0;
      };

      dock = {
        autohide = true;
        show-recents = false;
        launchanim = true;
        orientation = "left";
        tilesize = 48;
        mru-spaces = false;
      };

      finder = {
        AppleShowAllExtensions = true;
        _FXShowPosixPathInTitle = false;
      };

      trackpad = {
        Clicking = true;
        TrackpadThreeFingerDrag = false; # true is no bueno
      };

      screencapture.location = "~/Pictures/Screenshots";
      screensaver.askForPasswordDelay = 10; # in seconds
    };

    keyboard = {
      enableKeyMapping = true;
      remapCapsLockToEscape = true;
    };
  };
}
