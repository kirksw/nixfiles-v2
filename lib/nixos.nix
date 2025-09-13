{
  lib,
  inputs,
  self,
  overlays ? [ ],
}:

let
  inherit (inputs)
    nixpkgs
    sops-nix
    disko
    home-manager
    ;
  homeManagerHelpers = import ./homemanager.nix {
    inherit lib inputs self;
    gitProfiles = import ./git-profiles.nix {
      inherit
        lib
        inputs
        overlays
        ;
    };
  };

  mkNixosSystem =
    hostname: config:
    nixpkgs.lib.nixosSystem {
      system = config.system;
      specialArgs = {
        inherit inputs self;
      }
      // config;
      modules = [
        disko.nixosModules.disko
        { nixpkgs.overlays = overlays; }
        sops-nix.darwinModules.sops
        home-manager.nixosModules.home-manager
        config.hostModule
        (homeManagerHelpers.mkHomeManagerModule config)
      ];
    };
in
{
  inherit mkNixosSystem;
}
