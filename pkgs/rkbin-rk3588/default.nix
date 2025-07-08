{
  stdenvNoCC,
  fetchFromGitHub,
}:
stdenvNoCC.mkDerivation {
  pname = "rkbin-rk3588";
  version = "2025.07.07";

  # https://github.com/armbian/rkbin/tree/master
  src = fetchFromGitHub {
    owner = "armbian";
    repo = "rkbin";
    rev = "669fe029e9dcff3580e68c1abaa94f35d4166823";
    sha256 = "";
  };

  installPhase = ''
    mkdir $out && cp rk35/rk3588* $out/
  '';
}
