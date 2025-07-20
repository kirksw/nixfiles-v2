{ user, inputs, ... }:

{
  nix-homebrew = {
    inherit user;
    enable = true;
    mutableTaps = false;
    taps = {
      "homebrew/core" = inputs.homebrew-core;
      "homebrew/cask" = inputs.homebrew-cask;
      "homebrew/bundle" = inputs.homebrew-bundle;
    };
  };
}
