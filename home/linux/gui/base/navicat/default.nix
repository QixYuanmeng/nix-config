{
  pkgs,
  config,
  ...
}:
let
  navicat17-cs = (pkgs.callPackage ./navicat.nix {

  });
in
# processing audio/video
{
  home.packages = with pkgs; [
    navicat17-cs
  ];
}