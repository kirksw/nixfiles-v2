{ user, inputs, ... }:

{
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
