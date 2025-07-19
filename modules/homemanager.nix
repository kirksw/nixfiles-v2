{ user, hostModule, inputs, nixpkgsStable }:

{ config, pkgs, system, ... }:

let
  pkgsStable = import nixpkgsStable {
    inherit system;
    config.allowUnfree = true;
  };
in {
  home-manager.useGlobalPkgs     = true;
  home-manager.useUserPackages   = true;

  home-manager.users = {
    "${user}" = import hostModule;
  };

  home-manager.sharedModules = [
    ./shared     # adjust if you want to pull this via inputs instead
  ];

  home-manager.extraSpecialArgs = {
    inherit inputs;
    inherit pkgsStable;
  };
}
