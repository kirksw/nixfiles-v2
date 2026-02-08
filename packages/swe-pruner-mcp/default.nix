{
  lib,
  makeWrapper,
  ripgrep,
  python312Packages,
}:

python312Packages.buildPythonPackage rec {
  pname = "swe-pruner-mcp";
  version = "0.1.0";
  format = "pyproject";

  src = ./.;

  propagatedBuildInputs = with python312Packages; [
    mcp
    torch
    transformers
    huggingface-hub
    pydantic
  ];

  nativeCheckInputs = with python312Packages; [
    pytestCheckHook
  ] ++ [
    ripgrep
  ];

  nativeBuildInputs = with python312Packages; [
    hatchling
  ] ++ [
    makeWrapper
  ];

  pythonImportsCheck = [ "swe_pruner_mcp.server" ];
  disabledTests = [ ];

  postFixup = ''
    wrapProgram "$out/bin/swe-pruner-mcp" \
      --prefix PATH : "${lib.makeBinPath [ ripgrep ]}"
  '';

  meta = with lib; {
    description = "SWE-Pruner MCP server for context-aware code pruning";
    homepage = "https://github.com/Ayanami1314/swe-pruner";
    license = licenses.mit;
    maintainers = [ ];
  };
}
