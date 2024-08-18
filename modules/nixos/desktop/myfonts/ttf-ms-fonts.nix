{ stdenv, lib, fetchFromGitHub, ... }:

stdenv.mkDerivation rec {
  pname = "ttf-ms-fonts";
  version = "9.9.9";

  src = fetchFromGitHub {
    owner = "QixYuanmeng";
    repo = "ttf-ms-win10";
    rev = "60742666ee375df71a77c57db4bbf0713f34e44a";
    sha256 = "1kp85ih34svjyxms2qkvvxr6qra5kqisj4gjzmknv1vv2mpc5fyb";
  };

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/fonts/truetype
    install -D *.{ttf,ttc,TTF} $out/share/fonts/truetype/

    runHook postInstall
  '';

  meta = with lib; {
    homepage = "https://github.com/QixYuanmeng/ttf-ms-win10";
    description = "...";
    longDescription = ''
        i need this
    '';
    license = licenses.unfree;
    platforms = platforms.all;
  };
}