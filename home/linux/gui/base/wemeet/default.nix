{
  pkgs,
  config,
  ...
}:
let
  wemeet-bin-bwrap = pkgs.callPackage ./wemeet-bin-bwrap.nix {};
in
# processing audio/video
{
  home.packages = with pkgs; [
    wemeet-bin-bwrap
  ];
}