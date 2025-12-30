{
  lib,
  inputs,
  overlays ? [ ],
}:

let
  inherit (inputs) pkgs self;

  mkApp = scriptName: system: {
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
