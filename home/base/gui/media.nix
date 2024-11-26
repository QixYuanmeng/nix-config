{
  pkgs,
  config,
  ...
}:
let
  my-wpsoffice-cn = pkgs.wpsoffice-cn.overrideAttrs (oldAttrs: {
    nativeBuildInputs = oldAttrs.nativeBuildInputs or [] ++ [ pkgs.makeWrapper ];
    postFixup = ''
      # Add environment variables to the WPS Office executables
      for i in wps wpp et wpspdf; do
        wrapProgram $out/bin/$i \
          --set LANG "zh_CN.UTF-8"
      done
    '';
  });
in
# processing audio/video
{
  home.packages = with pkgs; [
    ffmpeg-full

    # images
    viu # Terminal image viewer with native support for iTerm and Kitty
    imagemagick
    graphviz
    my-wpsoffice-cn
    libwps
  ];
}