self: super: with super; { 
  fuzzyclone = super.stdenv.mkDerivation rec {
    pname = "fuzzy-clone";
    version = "v0.5.0";
      
    src = super.fetchurl {
      url = "https://github.com/lunarway/${pname}/releases/download/${version}/${pname}-darwin-amd64";
      sha256 = "sha256-76AaSUTBXQmIZQnpxrR25QrJSEtkOUouZCohCw2YN7M=";
    };

    dontUnpack = true;

    installPhase = ''
      mkdir -p $out/bin
      install -Dm755 ${src} $out/bin/${pname}
    '';
  };
}
