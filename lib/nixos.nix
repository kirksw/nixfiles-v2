{
  lib,
  inputs,
  self,
  overlays ? [ ],
}:

let
  inherit (inputs)
    nixpkgs
    nixpkgs-unstable
    sops-nix
    disko
    home-manager
    ;
  homeManagerHelpers = import ./homemanager.nix {
    inherit lib inputs self;
  };

  mkNixosSystem =
    hostname: config:
    let
      # Create unstable pkgs for this system
      pkgs-unstable = import nixpkgs-unstable {
        system = config.system;
        config.allowUnfree = true;
      };
    in
    nixpkgs.lib.nixosSystem {
      inherit (config) system;
      specialArgs = {
        inherit inputs self pkgs-unstable;
      }
      // config;
      modules = [
        disko.nixosModules.disko
        sops-nix.nixosModules.sops
        config.hostModule
        { nixpkgs.overlays = overlays; }
      ]
      ++ lib.optionals (config.enableHomeManager or false) [
        home-manager.nixosModules.home-manager
        (homeManagerHelpers.mkHomeManagerModule config)
      ];
    };
in
{
  inherit mkNixosSystem;
}
