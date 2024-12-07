{
  pkgs,
  config,
  ...
}:
let
  my-wpsoffice-cn = (pkgs.callPackage ./freetype2-wps.nix {
    qtbase = pkgs.libsForQt5.qt5.qtbase;
    useChineseVersion = true;
  });

  my-wpsoffice-365 = (pkgs.callPackage ./wpsoffice-365.nix {
    use365Version = true;
    useChineseVersion = false;
  });
in
# processing audio/video
{
  home.packages = with pkgs; [
    my-wpsoffice-cn
    libwps
    # my-wpsoffice-365
  ];
}