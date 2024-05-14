{
  pkgs,
  pkgs-unstable,
  ...
}: {
  home.packages = with pkgs; [
    # native wayland support (unstable)
    wineWowPackages.waylandFull
  ];
}
