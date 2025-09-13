{
  lib,
  inputs,
  overlays ? [ ],
}:

let
  inherit (inputs) nixpkgs self;

  mkApp = scriptName: system: {
    type = "app";
    program = "${
      (nixpkgs.legacyPackages.${system}.writeScriptBin scriptName ''
        #!${nixpkgs.legacyPackages.${system}.runtimeShell}
        PATH=${nixpkgs.legacyPackages.${system}.git}/bin:$PATH
        echo "Running ${scriptName} for ${system}"
        exec ${self}/apps/${system}/${scriptName}
      '')
    }/bin/${scriptName}";
  };
in
{
  inherit mkApp;
}
