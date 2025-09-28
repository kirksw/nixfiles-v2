{
  lib,
  inputs,
  self,
}:

let
  inherit (inputs);
  homeManagerHelpers = import ./homemanager.nix {
    inherit
      lib
      inputs
      self
      ;
  };

  mkNixosSystem =
    hostname: config:
    lib.nixosSystem {
      system = config.system;
      specialArgs = {
        inherit inputs self;
      }
      // config;
      modules = [
        { nixpkgs.overlays = (config.overlays or [ ]); }
        inputs.sops-nix.nixosModules.sops
        inputs.home-manager.nixosModules.home-manager
        config.hostModule
        (homeManagerHelpers.mkHomeManagerModule config)
      ];
    };
in
{
  inherit mkNixosSystem;
}
