{
  pkgs ? import <nixpkgs> { },
}:

pkgs.python312Packages.buildPythonPackage rec {
  pname = "swe-pruner-mcp";
  version = "0.1.0";
  format = "pyproject";

  src = pkgs.fetchFromGitHub {
    owner = "Ayanami1314";
    repo = "swe-pruner";
    rev = "public";
    hash = "sha256-49fqL46xnSbOrt1Uqc5b9cYK0Ql5L7OXMtmyu/vbb1I=";
  };

  propagatedBuildInputs = with pkgs.python312Packages; [
    mcp
    torch
    transformers
    huggingface-hub
    pydantic
  ];

  postInstall = ''
    mkdir -p $out/bin

    cat > $out/bin/swe-pruner-mcp << 'EOF'
    #!/bin/sh
    exec ${pkgs.python312Packages.python.interpreter} -m swe_pruner_mcp.server "$@"
    EOF

    chmod +x $out/bin/swe-pruner-mcp
  '';

  meta = with pkgs.lib; {
    description = "SWE-Pruner MCP server for context-aware code pruning";
    homepage = "https://github.com/Ayanami1314/swe-pruner";
    license = licenses.mit;
    maintainers = [ ];
  };
}
