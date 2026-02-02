{
  lib,
  inputs,
  self,
}:

let
  inherit (inputs) darwin nixpkgs-unstable;
  homeManagerHelpers = import ./homemanager.nix {
    inherit
      lib
      inputs
      self
      ;
  };

  mkDarwinSystem =
    hostname: config:
    let
      # Create unstable pkgs for this system
      pkgs-unstable = import nixpkgs-unstable {
        system = config.system;
        config.allowUnfree = true;
      };
    in
    darwin.lib.darwinSystem {
      specialArgs = {
        inherit inputs self pkgs-unstable;
      }
      // config;
      modules = [
        {
          nixpkgs.hostPlatform = config.system;
          nixpkgs.overlays = (config.overlays or [ ]);
        }
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
