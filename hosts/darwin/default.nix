{ pkgs, user, ... }:
{
  imports = [
    ../../modules/shared
    ../../modules/darwin
    ../../modules/darwin/homebrew.nix
  ];

  dagger.enable = true;
  lunar-tools.enable = true;

  nixpkgs = {
    config.allowUnfree = true;
  };

  users.users.${user} = with pkgs; {
    home = "/Users/${user}";
    shell = zsh;
  };

  ids.gids.nixbld = 350;

  nix = {
    # Note: turn off for determinant systems nix
    settings = {
      trusted-users = [
        "@admin"
        "${user}"
      ];
      # substituters = [
      #   "https://nix-community.cachix.org"
      #   "https://cache.nixos.org"
      # ];
      # trusted-public-keys = [ "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY=" ];
      builders-use-substitutes = true;
    };
    optimise = {
      automatic = true;
      interval = {
        Weekday = 4;
        Hour = 2;
        Minute = 0;
      };
    };
    gc = {
      automatic = true;
      interval = {
        Weekday = 0;
        Hour = 2;
        Minute = 0;
      };
      options = "--delete-older-than 30d";
    };
    extraOptions = ''
      experimental-features = nix-command flakes
      extra-platforms = x86_64-darwin aarch64-darwin
    '';
    linux-builder = {
      enable = true;
      ephemeral = true;
      maxJobs = 4;
      config = {
        virtualisation = {
          darwin-builder = {
            diskSize = 40 * 1024;
            memorySize = 8 * 1024;
          };
          cores = 6;
        };
      };
    };
    distributedBuilds = true;
  };

  # determinate-nix.customSettings = {
  #   lazy-trees = true;
  #   extra-trusted-users = [
  #     "kisw"

  #     "x86_64-linux"
  #   ];
  #   builders = "@${buildersConf}";
  #   builders-use-substitutes = true;
  # };

  # linux-builder.enable = builder-enable;
  tailscale.enable = true;

  # Turn off NIX_PATH warnings now that we're using flakes
  system.checks.verifyNixPath = false;

  environment.shells = with pkgs; [
    zsh
  ];
  programs.zsh.enable = true;

  environment.variables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
  };

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
    };
  };

  homebrew = {
    enable = true;

    global = {
      brewfile = true;
      autoUpdate = true;
    };

    brewPrefix = "/opt/homebrew/bin"; # needed for arm64
    casks = pkgs.callPackage ../../modules/darwin/casks.nix { };

    onActivation = {
      autoUpdate = true;
      upgrade = true;
      cleanup = "zap";
    };

    brews = [
      # "ollama"
      # "dagger"
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
      "xcode" = 497799835;
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
      on-focused-monitor-changed = [ "move-mouse monitor-lazy-center" ];
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

        alt-q = "close";

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

        # alt-a = "exec-and-forget open -a /Applications/Arc.app";
        # alt-z = "exec-and-forget open -a /Applications/Zed.app";
        # alt-i = "exec-and-forget open -a '/Applications/IntelliJ IDEA.app'";
        # alt-d = "exec-and-forget open -a /Applications/DataGrip.app";
        alt-s = "exec-and-forget open -a /Applications/Slack.app";
        alt-g = "exec-and-forget open -a /opt/homebrew/bin/ghostty";
      };
      mode.service.binding = {
        esc = [
          "reload-config"
          "mode main"
        ];
        r = [
          "flatten-workspace-tree"
          "mode main"
        ];
        f = [
          "layout floating tiling"
          "mode main"
        ];
        backspace = [
          "close-all-windows-but-current"
          "mode main"
        ];

        alt-shift-h = [
          "join-with left"
          "mode main"
        ];
        alt-shift-j = [
          "join-with down"
          "mode main"
        ];
        alt-shift-k = [
          "join-with up"
          "mode main"
        ];
        alt-shift-l = [
          "join-with right"
          "mode main"
        ];
      };
    };
  };

  # services.sketchybar = {
  #   enable = true;
  #   config = ''
  #     sketchybar --bar height=24
  #     sketchybar --update
  #   '';
  # };

  services.jankyborders = {
    enable = true;
    width = 8.0;
    hidpi = true;
    active_color = "0xFFFFFF";
    inactive_color = "0xCCCCCC";
  };
}
