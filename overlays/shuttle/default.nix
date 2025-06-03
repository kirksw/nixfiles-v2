self: super: with super; { 
  shuttle = let
    pname = "shuttle";
    version = "0.24.3";
  in pkgs.buildGoModule {
    pname = pname;
    version = version;
    src = pkgs.fetchFromGitHub {
      owner = "lunarway";
      repo = pname;
      rev = "v${version}";
      sha256 = "sha256-5tasK7eGzcs87wIOFFVRP23xFnobmn1YEHlLIHuAGS8=";
    };

    vendorHash = "sha256-qZoV1TPUR7mMFF4STqXxYbTyQGiAlIPR2WvwqMdqrRY=";
    doCheck = false;
  };
}
