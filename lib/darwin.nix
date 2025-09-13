{
  lib,
  inputs,
  self,
}:

let
  inherit (inputs) darwin;
  homeManagerHelpers = import ./homemanager.nix {
    inherit
      lib
      inputs
      self
      ;
  };

  mkDarwinSystem =
    hostname: config:
    darwin.lib.darwinSystem {
      system = config.system;
      specialArgs = {
        inherit inputs self;
      }
      // config;
      modules = [
        { nixpkgs.overlays = (config.overlays or [ ]); }
        inputs.sops-nix.darwinModules.sops
        inputs.home-manager.darwinModules.home-manager
        config.hostModule
        (homeManagerHelpers.mkHomeManagerModule config)
      ]
      ++ lib.optionals config.enableHomebrew [
        inputs.nix-homebrew.darwinModules.nix-homebrew
      ];
    };
in
{
  inherit mkDarwinSystem;
}
