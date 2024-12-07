{ stdenv, fetchurl, autoPatchelfHook, lib, wrapGAppsHook,glib, qt6 ,libselinux, makeWrapper, unzip,libxcrypt, e2fsprogs,libxcb, zlib, libxml2, curl, libGL, xorg, cjson, libgpg-error, libassuan, libuuid, fontconfig, freetype, expat, gnutls, gpgme, libkrb5, pango}:
stdenv.mkDerivation rec {
  pname = "navicat17-premium-cs";
  version = "17.0.4";

  src = fetchurl {
    url = "https://dn.navicat.com/download/navicat17-premium-cs-x86_64.AppImage";
    sha256 = "sha256-b6tuBpXFH9jO3He6d3xrWFEJ6MccUMWPToR+NKpSKMU=";
  };

  nativeBuildInputs = [ autoPatchelfHook makeWrapper unzip wrapGAppsHook qt6.wrapQtAppsHook ];

  buildInputs = [
    qt6.qtbase qt6.qtwayland libxcb zlib libxcrypt libxml2 curl e2fsprogs libGL xorg.libX11 cjson libgpg-error libassuan libuuid fontconfig freetype expat gnutls gpgme libkrb5 pango
  ];

  unpackPhase = ''
    cp $src navicat17-premium-cs-${version}.AppImage
    chmod +x navicat17-premium-cs-${version}.AppImage
    ./navicat17-premium-cs-${version}.AppImage --appimage-extract
  '';

  preFixup = ''
  patchelf --replace-needed libcrypt.so.1 ${libxcrypt}/lib/libcrypt.so.2 $out/opt/$pname/usr/lib/pq-g/libpq.so.5.5
  patchelf --replace-needed libcrypt.so.1 ${libxcrypt}/lib/libcrypt.so.2 $out/opt/$pname/usr/lib/pq-g/libpq_ce.so.5.5
  
  # 替换包里的libselinux.so.1
  patchelf --replace-needed libselinux.so.1 ${libselinux}/lib/libselinux.so.1 $out/opt/$pname/usr/lib/pq-g/libpq.so.5.5
  '';

  installPhase = ''
    mkdir -p $out/opt/$pname
    cp -r squashfs-root/* $out/opt/$pname/

    mkdir -p $out/share/applications
    cp squashfs-root/usr/share/applications/navicat.desktop $out/share/applications/

    mkdir -p $out/share/icons/hicolor/256x256/apps
    cp squashfs-root/usr/share/icons/hicolor/256x256/apps/navicat-icon.png $out/share/icons/hicolor/256x256/apps/

    # 删除自带的libselinux.so.1
    rm $out/opt/$pname/usr/lib/libselinux.so.1
    # 链接到系统的libselinux.so.1
    ln -s ${libselinux}/lib/libselinux.so.1 $out/opt/$pname/usr/lib/libselinux.so.1

    # 自带的 glib太老，换掉
    rm $out/opt/$pname/usr/lib/glib/libglib-2.0.so.0
    ln -s ${glib.out}/lib/libglib-2.0.so.0 $out/opt/$pname/usr/lib/glib/libglib-2.0.so.0

    # 删除自带的libgobject-2.0.so.0
    # rm $out/opt/$pname/usr/lib/libgobject-2.0.so.0
    # 链接到系统的libgobject-2.0.so.0
    # ln -s ${glib.out}/lib/libgobject-2.0.so.0 $out/opt/$pname/usr/lib/libgobject-2.0.so.0

    #增加qt Wayland plugin 支持
    wrapQtAppsHook $out/opt/$pname/usr/bin/navicat
    
    mkdir -p $out/bin
    makeWrapper $out/opt/$pname/AppRun $out/bin/navicat \
      --prefix QT_PLUGIN_PATH : $out/opt/$pname/usr/plugins \
      --set LANG zh_CN.UTF-8
  '';

  meta = with lib; {
    description = "Navicat Premium is a multi-connection database development tool. (Chinese Simplified)";
    homepage = "https://www.navicat.com.cn/navicat-17-highlights";
    license = licenses.unfree;
    platforms = [ "x86_64-linux" ];
  };
}