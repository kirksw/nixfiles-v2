{ nixpkgs, mylibs }:
{
  system,
  packageNames,
  packages,
}:
let
  pkgs = import nixpkgs { inherit system; };
  updateCommandFor =
    name:
    let
      pkg = packages.${name};
      passthru = pkg.passthru or { };
    in
    if passthru ? updateScript then
      toString passthru.updateScript
    else
      "echo 'No updateScript for ${name}'";

  updateAllPackages = pkgs.writeShellScriptBin "update-packages" ''
    set -euo pipefail
    cd ${toString ../.}
    echo "Updating all packages..."
    ${builtins.concatStringsSep "\n" (
      map (name: ''
        echo "-> Updating ${name}..."
        ${updateCommandFor name}
      '') packageNames
    )}
    echo "Done!"
  '';
in
{
  build = mylibs.app.mkApp "build" system;
  switch = mylibs.app.mkApp "switch" system;
  rollback = mylibs.app.mkApp "rollback" system;
  update-packages = {
    type = "app";
    program = "${updateAllPackages}/bin/update-packages";
  };
}
