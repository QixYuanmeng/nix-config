{
  pkgs,
  config,
  ...
}:
let
  gtkwave = pkgs.callPackage ./gtkwave.nix {};
in
# processing audio/video
{
  home.packages = with pkgs; [
    gtkwave
    iverilog
  ];
}