{ pkgs, ... }: 
let
  ttf-ms-fonts = pkgs.callPackage ./ttf-ms-fonts.nix {};
in
{
  environment.systemPackages = with pkgs; [
    ttf-ms-fonts
  ];
}