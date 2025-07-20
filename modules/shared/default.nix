{ lib, ... }:

let
  nixFiles = builtins.filter (f: lib.hasSuffix ".nix" f) (lib.filesystem.listFilesRecursive ./.);

  excluded = [
    (toString ./default.nix)
    (toString ./template.nix)
  ];

  isSubdir =
    f:
    let
      relPathParts = lib.splitString "/" (lib.removePrefix (toString ./. + "/") (toString f));
    in
    builtins.length relPathParts > 1;

  filtered = builtins.filter (f: !(builtins.elem (toString f) excluded) && isSubdir f) nixFiles;
in
{
  imports = map import filtered;

  nixpkgs = {
    config = {
      allowUnfree = true;
      allowBroken = true;
      allowInsecure = false;
      allowUnsupportedSystem = true;
    };

    overlays =
      # Apply each overlay found in the /overlays directory
      let
        path = ../../overlays;
      in
      with builtins;
      map (n: import (path + ("/" + n))) (
        filter (n: match ".*\\.nix" n != null || pathExists (path + ("/" + n + "/default.nix"))) (
          attrNames (readDir path)
        )
      );
  };
}
