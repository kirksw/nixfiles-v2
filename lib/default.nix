{
  self,
  lib,
  inputs,
}:

{
  homemanager = import ./homemanager.nix {
    inherit
      lib
      inputs
      ;
  };
  darwin = import ./darwin.nix {
    inherit
      lib
      inputs
      self
      ;
  };
  nixos = import ./nixos.nix {
    inherit
      lib
      inputs
      self
      ;
  };
  app = import ./app.nix {
    inherit
      lib
      inputs
      ;
  };
}
