final: prev: {
  pass-cli = prev.stdenv.mkDerivation {
    # fetch binary paths, versions and hex hashes from
    # https://proton.me/download/pass-cli/versions.json
    pname = "pass-cli";
    version = "1.3.2";

    src = prev.fetchurl {
      url = "https://proton.me/download/pass-cli/1.3.2/pass-cli-macos-aarch64";
      # convert hash from json using `nix hash to-sri sha256:<hash>`
      sha256 = "sha256-B+hmxagP5Ls+Jc8DZN8Y9fvdrTq+HkMICUzMVsd8aU4=";
    };

    dontUnpack = true;
    dontBuild = true;

    installPhase = ''
      mkdir -p $out/bin
      cp $src $out/bin/pass-cli
      chmod +x $out/bin/pass-cli
    '';
  };
}
