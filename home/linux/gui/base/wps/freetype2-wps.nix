{ lib
, stdenv
, fetchurl
, dpkg
, autoPatchelfHook
, makeWrapper
, alsa-lib
, at-spi2-core
, libtool
, libxkbcommon
, nspr
, mesa
, libtiff
, udev
, gtk3
, qtbase
, xorg
, cups
, pango
, runCommandLocal
, libmysqlclient
, curl
, coreutils
, cacert
, freetype
, useChineseVersion ? false
}:

let
  pkgVersion = "11.1.0.11723";
  url =
    if useChineseVersion then
      "https://wps-linux-personal.wpscdn.cn/wps/download/ep/Linux2019/${lib.last (lib.splitVersion pkgVersion)}/wps-office_${pkgVersion}_amd64.deb"
    else
      "https://wdl1.pcfg.cache.wpscdn.com/wpsdl/wpsoffice/download/linux/${lib.last (lib.splitVersion pkgVersion)}/wps-office_${pkgVersion}.XA_amd64.deb";
  hash =
    if useChineseVersion then
      "sha256-vpXK8YyjqhFdmtajO6ZotYACpe5thMct9hwUT3advUM="
    else
      "sha256-o8njvwE/UsQpPuLyChxGAZ4euvwfuaHxs5pfUvcM7kI=";
  uri = builtins.replaceStrings [ "https://wps-linux-personal.wpscdn.cn" ] [ "" ] url;
  securityKey = "7f8faaaa468174dc1c9cd62e5f218a5b";
in
stdenv.mkDerivation rec {
  pname = "wpsoffice";
  version = pkgVersion;

  src = runCommandLocal (if useChineseVersion then "wps-office_${version}_amd64.deb" else "wps-office_${version}.XA_amd64.deb")
    {
      outputHashMode = "recursive";
      outputHashAlgo = "sha256";
      outputHash = hash;

      nativeBuildInputs = [ curl coreutils ];

      SSL_CERT_FILE = "${cacert}/etc/ssl/certs/ca-bundle.crt";
    } ''
    timestamp10=$(date '+%s')
    md5hash=($(echo -n "${securityKey}${uri}$timestamp10" | md5sum))

    curl \
    --retry 3 --retry-delay 3 \
    "${url}?t=$timestamp10&k=$md5hash" \
    > $out
  '';

  unpackCmd = "dpkg -x $src .";
  sourceRoot = ".";

  nativeBuildInputs = [
    dpkg
    autoPatchelfHook
    makeWrapper
  ];

  buildInputs = [
    alsa-lib
    at-spi2-core
    libtool
    libxkbcommon
    nspr
    mesa
    libtiff
    udev
    gtk3
    qtbase
    xorg.libXdamage
    xorg.libXtst
    xorg.libXv
  ];

  dontWrapQtApps = true;

  runtimeDependencies = map lib.getLib [
    cups
    pango
  ];

  autoPatchelfIgnoreMissingDeps = [
    # distribution is missing libkappessframework.so
    "libkappessframework.so"
    # qt4 support is deprecated
    "libQtCore.so.4"
    "libQtNetwork.so.4"
    "libQtXml.so.4"
  ];

  installPhase = ''
    runHook preInstall
    prefix=$out/opt/kingsoft/wps-office
    mkdir -p $out
    cp -r opt $out
    cp -r usr/* $out
    for i in wps wpp et wpspdf; do
      substituteInPlace $out/bin/$i \
        --replace /opt/kingsoft/wps-office $prefix
    done
    for i in $out/share/applications/*;do
      substituteInPlace $i \
        --replace /usr/bin $out/bin
    done

    rm -f $out/opt/kingsoft/wps-office/office6/libfreetype.so.6
    ln -sf ${freetype.overrideAttrs (e: rec {
      patches = e.patches ++ [
        ./0000-WPS-compatiblity.patch
        ./0001-Enable-long-PCF-family-names.patch
       ];
    })}/lib/libfreetype.so.6 $out/opt/kingsoft/wps-office/office6
    runHook postInstall
  '';

  preFixup = ''
    # The following libraries need libtiff.so.5, but nixpkgs provides libtiff.so.6
    patchelf --replace-needed libtiff.so.5 libtiff.so $out/opt/kingsoft/wps-office/office6/{libpdfmain.so,libqpdfpaint.so,qt/plugins/imageformats/libqtiff.so,addons/pdfbatchcompression/libpdfbatchcompressionapp.so}
    # dlopen dependency
    patchelf --add-needed libudev.so.1 $out/opt/kingsoft/wps-office/office6/addons/cef/libcef.so
    patchelf --add-needed libjpeg.so $out/opt/kingsoft/wps-office/office6/libwpsmain.so
  '';


  postFixup = ''
    for exe in $out/bin/*; do
      wrapProgram $exe \
        --set LANG "zh_CN.UTF-8"
    done
  '';


  meta = with lib; {
    description = "Office suite, formerly Kingsoft Office";
    homepage = "https://www.wps.com";
    platforms = [ "x86_64-linux" ];
    sourceProvenance = with sourceTypes; [ binaryNativeCode ];
    hydraPlatforms = [ ];
    license = licenses.unfreeRedistributable;
    maintainers = with maintainers; [ mlatus th0rgal rewine pokon548 ];
  };
}