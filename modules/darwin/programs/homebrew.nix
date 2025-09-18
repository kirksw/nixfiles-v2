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
    casks = pkgs.callPackage ../casks.nix { };

    onActivation = {
      autoUpdate = true;
      upgrade = true;
      cleanup = "zap";
    };

    brews = pkgs.callPackage ../brews.nix { };

    # These app IDs are from using the mas CLI app
    # $ nix shell nixpkgs#mas
    # $ mas search <app name>
    masApps = {
      "xcode" = 497799835;
    };
  };

  nix-homebrew = {
    inherit user;
    enable = true;
    autoMigrate = true;
    mutableTaps = true;
  };
}
