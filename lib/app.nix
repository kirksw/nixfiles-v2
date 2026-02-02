{
  lib,
  inputs,
}:

let
  inherit (inputs) nixpkgs self;

  mkApp = scriptName: system:
    let
      pkgs = import nixpkgs { inherit system; };
    in
    {
      type = "app";
      program = "${(pkgs.writeScriptBin scriptName ''
        #!${pkgs.runtimeShell}
        PATH=${pkgs.git}/bin:$PATH
        echo "Running ${scriptName} for ${system}"
        exec ${self}/apps/${system}/${scriptName}
      '')}/bin/${scriptName}";
    };
in
{
  inherit mkApp;
}
