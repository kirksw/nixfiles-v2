{
  lib,
  self,
  inputs,
}:

{
  mkHomeManagerModule = config: {
    home-manager = {
      useGlobalPkgs = true;
      useUserPackages = true;
      backupFileExtension = "backup";
      users.${config.user} = import config.homeModule;
      sharedModules = [
        inputs.sops-nix.homeManagerModules.sops
        ../modules/home
      ];
      extraSpecialArgs = {
        inherit inputs self;
      }
      // config;
    };
  };
}
