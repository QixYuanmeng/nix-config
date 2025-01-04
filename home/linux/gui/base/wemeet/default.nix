{
  pkgs,
  config,
  ...
}:
let
  wemeet-bin-bwrap = pkgs.libsForQt5.callPackage ./wemeet-bin-bwrap.nix {
    useWaylandScreenshare = true;
  };
in
# processing audio/video
{
  home.packages = with pkgs; [
    wemeet-bin-bwrap
  ];
}