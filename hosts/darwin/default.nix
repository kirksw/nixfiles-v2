{ pkgs, pkgs-unstable, ... }:

let
  user = "kirk";
in {
  imports = [
    ../../modules/shared
  ];

  # Auto upgrade nix package and the daemon service.
  services.nix-daemon.enable = true;
  nixpkgs.config.allowUnfree = true;

  users.users.kirk = with pkgs; {
    home = "/Users/kirk";
    shell = zsh;
  };

  # Setup user, packages, programs
  nix = {
    # TODO: stable vs unstable
    # stable mode
    # package = pkgs.nixFlakes;
    # future: packages = pkgs.nixVersions.latest;
    # unstable mode
    package = pkgs.nixVersions.git;
    settings.trusted-users = [ "@admin" "${user}" ];

    gc = {
      user = "root";
      automatic = true;
      interval = { Weekday = 0; Hour = 2; Minute = 0; };
      options = "--delete-older-than 30d";
    };

    # Turn this on to make command line easier
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
  };

  # Turn off NIX_PATH warnings now that we're using flakes
  system.checks.verifyNixPath = false;

  # Load configuration that is shared across systems
  environment.systemPackages = with pkgs; (import ../../modules/shared/packages.nix { inherit pkgs; });

  environment.shells = with pkgs; [
    zsh
  ];
  programs.zsh.enable = true;

  environment.variables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
    INFISICAL_API_URL = "https://env.gowish.com/api";
  };

  fonts.packages = with pkgs; [
    (nerdfonts.override {
      fonts = [
      "FiraCode"
      ];
    })
    dejavu_fonts
    jetbrains-mono
    font-awesome
  ];

  security.pam.enableSudoTouchIdAuth = true;

  system = {
    stateVersion = 4;

    defaults = {
      NSGlobalDomain = {
        AppleInterfaceStyle = "Dark";
        AppleShowAllExtensions = true;
        ApplePressAndHoldEnabled = false;
        NSWindowShouldDragOnGesture = true;

        # 120, 90, 60, 30, 12, 6, 2
        KeyRepeat = 2;

        # 120, 94, 68, 35, 25, 15
        InitialKeyRepeat = 15;

        # Automatically hide and show the menu bar
        # TODO: remove after sketchybar
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
      nonUS.remapTilde = true;
    };
  };

  homebrew = {
    enable = true;

    global = {
      brewfile = true;
      autoUpdate = false;
    };

    brewPrefix = "/opt/homebrew/bin"; # needed for arm64
    casks = pkgs.callPackage ../../modules/darwin/casks.nix {};

    onActivation = {
      autoUpdate = false;
      upgrade = false;
      cleanup = "zap";
    };

    brews = [
      #"infisical@0.24.0"
    ];

    # These app IDs are from using the mas CLI app
    # mas = mac app store
    # https://github.com/mas-cli/mas
    #
    # $ nix shell nixpkgs#mas
    # $ mas search <app name>
    #
    # If you have previously added these apps to your Mac App Store profile (but not installed them on this system),
    # you may receive an error message "Redownload Unavailable with This Apple ID".
    # This message is safe to ignore. (https://github.com/dustinlyons/nixos-config/issues/83)
    masApps = {
      "xcode"     = 497799835;
    };
  };

  services.aerospace = {
    enable = true;
    settings = {
      start-at-login = false;
      enable-normalization-flatten-containers = true;
      enable-normalization-opposite-orientation-for-nested-containers = true;
      accordion-padding = 50;
      default-root-container-layout = "tiles";
      default-root-container-orientation = "auto";
      on-focused-monitor-changed = ["move-mouse monitor-lazy-center"];
      automatically-unhide-macos-hidden-apps = true;

      key-mapping = {
        preset = "qwerty";
      };
      gaps = {
        outer.left = 8;
        outer.bottom = 8;
        outer.top = 8;
        outer.right = 8;
        inner.horizontal = 8;
        inner.vertical = 8;
      };
      mode.main.binding = {
        alt-ctrl-shift-f = "fullscreen";
        alt-ctrl-f = "layout floating";

        alt-slash = "layout tiles horizontal vertical";
        alt-comma = "layout accordion horizontal vertical";

        alt-h = "focus left";
        alt-j = "focus down";
        alt-k = "focus up";
        alt-l = "focus right";

        alt-shift-h = "move left";
        alt-shift-j = "move down";
        alt-shift-k = "move up";
        alt-shift-l = "move right";

        alt-shift-minus = "resize smart -50";
        alt-shift-equal = "resize smart +50";

        alt-1 = "workspace 1";
        alt-2 = "workspace 2";
        alt-3 = "workspace 3";
        alt-4 = "workspace 4";
        alt-5 = "workspace 5";

        alt-shift-1 = "move-node-to-workspace 1";
        alt-shift-2 = "move-node-to-workspace 2";
        alt-shift-3 = "move-node-to-workspace 3";
        alt-shift-4 = "move-node-to-workspace 4";
        alt-shift-5 = "move-node-to-workspace 5";

        alt-tab = "workspace-back-and-forth";
        alt-shift-tab = "move-workspace-to-monitor --wrap-around next";
        alt-shift-semicolon = "mode service";

        alt-a = "exec-and-forget open -a /Applications/Arc.app";
        alt-w = "exec-and-forget open -a /etc/profiles/per-user/kirk/bin/wezterm";
        alt-z = "exec-and-forget open -a /Applications/Zed.app";
        alt-i = "exec-and-forget open -a '/Applications/IntelliJ IDEA.app'";
        alt-d = "exec-and-forget open -a /Applications/DataGrip.app";
        alt-s = "exec-and-forget open -a /Applications/Slack.app";
      };
      mode.service.binding = {
        esc = ["reload-config" "mode main"];
        r = ["flatten-workspace-tree" "mode main"];
        f = ["layout floating tiling" "mode main"];
        backspace = ["close-all-windows-but-current" "mode main"];

        alt-shift-h = ["join-with left" "mode main"];
        alt-shift-j = ["join-with down" "mode main"];
        alt-shift-k = ["join-with up" "mode main"];
        alt-shift-l = ["join-with right" "mode main"];
      };
    };
  };

  services.sketchybar = {
    enable = true;
    config = ''
      sketchybar --bar height=24
      sketchybar --update
    '';
  };

  services.jankyborders = {
    enable = true;
    width = 3.0;
    hidpi = true;
  };
}
