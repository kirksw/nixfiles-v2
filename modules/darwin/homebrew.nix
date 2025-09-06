{
  user,
  pkgs,
  ...
}:

{
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

  nix-homebrew = {
    inherit user;
    enable = true;
    mutableTaps = true;
    # taps = {
    #   "homebrew/core" = inputs.homebrew-core;
    #   "homebrew/cask" = inputs.homebrew-cask;
    #   "homebrew/bundle" = inputs.homebrew-bundle;
    # };
    # NOTE: below taps needed as flake inputs if using taps above
    # homebrew-bundle = {
    #   url = "github:homebrew/homebrew-bundle";
    #   flake = false;
    # };
    # homebrew-core = {
    #   url = "github:homebrew/homebrew-core";
    #   flake = false;
    # };
    # homebrew-cask = {
    #   url = "github:homebrew/homebrew-cask";
    #   flake = false;
    # };
  };
}
