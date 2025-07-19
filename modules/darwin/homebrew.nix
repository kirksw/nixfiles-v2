{ user, inputs, ... }: 

{
  nix-homebrew = {
    inherit user;
    enable = true;
    taps = {
      "homebrew/homebrew-core"   = inputs.homebrew-core;
      "homebrew/homebrew-cask"   = inputs.homebrew-cask;
      "homebrew/homebrew-bundle" = inputs.homebrew-bundle;
      "nikitabobko/homebrew-tap" = inputs.homebrew-nikitabobko;
      "dagger/homebrew-tap"      = inputs.homebrew-dagger;
    };
  };
}
