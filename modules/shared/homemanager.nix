{
  user,
  hostModule,
  inputs,
  nixpkgsStable,
  nixfiles,
  ...
}:

{
  config,
  pkgs,
  system,
  ...
}:

let
  pkgsStable = import nixpkgsStable {
    inherit system;
    config.allowUnfree = true;
  };
in
{
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    backupFileExtension = "bak";

    users = {
      "${user}" = import hostModule;
    };

    sharedModules = [
      ../home
    ];

    extraSpecialArgs = {
      inherit inputs;
      inherit pkgsStable;
      inherit nixfiles;
    };
  };
}
