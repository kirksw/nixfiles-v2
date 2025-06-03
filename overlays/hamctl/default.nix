self: super: with super; { 
  hamctl = super.stdenv.mkDerivation rec {
    pname = "release-manager";
    version = "v0.32.1";
    tool = "hamctl";
      
    src = super.fetchurl {
      url = "https://github.com/lunarway/${pname}/releases/download/${version}/${tool}-darwin-amd64";
      sha256 = "sha256-76AaSUTBXQmIZQnpxrR25QrJSEtkOUouZCohCw2YN7M=";
    };

    dontUnpack = true;

    installPhase = ''
      mkdir -p $out/bin
      install -Dm755 ${src} $out/bin/${tool}
    '';
  };
}
