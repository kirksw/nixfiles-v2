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

  #nix = {
  #  enable = true;
  #  settings = {
  #    max-jobs = "auto";
  #    cores = 0; # Use all cores
  #    trusted-users = [
  #      "@admin"
  #      "${user}"
  #    ];
  #    substituters = [
  #      "https://cache.nixos.org"
  #      "https://nix-community.cachix.org"
  #      "https://wezterm.cachix.org"
  #      "https://yazi.cachix.org"
  #    ];
  #    trusted-public-keys = [
  #      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
  #      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
  #      "yazi.cachix.org-1:Dcdz63NZKfvUCbDGngQDAZq6kOroIrFoyO064uvLh8k="
  #      "wezterm.cachix.org-1:kAbhjYUC9qvblTE+s7S+kl5XM1zVa4skO+E/1IDWdH0="
  #    ];
  #    builders-use-substitutes = true;
  #  };
  #  optimise = {
  #    automatic = true;
  #    interval = {
  #      Weekday = 4;
  #      Hour = 2;
  #      Minute = 0;
  #    };
  #  };
  #  gc = {
  #    automatic = true;
  #    interval = {
  #      Weekday = 0;
  #      Hour = 2;
  #      Minute = 0;
  #    };
  #    options = "--delete-older-than 30d";
  #  };

  #  extraOptions = ''
  #    experimental-features = nix-command flakes
  #    extra-platforms = x86_64-darwin aarch64-darwin
  #  '';
  #  linux-builder = {
  #    enable = true;
  #    ephemeral = true;
  #    maxJobs = 4;
  #    config = {
  #      virtualisation = {
  #        darwin-builder = {
  #          diskSize = 40 * 1024;
  #          memorySize = 8 * 1024;
  #        };
  #        cores = 6;
  #      };
  #    };
  #  };
  #  distributedBuilds = true;
  #};

  system.checks.verifyNixPath = false;

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
