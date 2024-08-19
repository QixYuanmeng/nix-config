{
  pkgs,
  pkgs-unstable,
  nur,
  ...
}: {
  home.packages = with pkgs; [
    # GUI apps
    # e-book viewer(.epub/.mobi/...)
    # do not support .pdf
    foliate

    # instant messaging
    telegram-desktop
    #discord
    pkgs-unstable.qq # https://github.com/NixOS/nixpkgs/tree/master/pkgs/applications/networking/instant-messengers/qq
    # pkgs-unstable.wechat-uos
    # remote desktop(rdp connect)
    remmina
    freerdp # required by remmina

    # misc
    flameshot
    ventoy # multi-boot usb creator

    pkgs.nur.repos.linyinfeng.wemeet

    wpsoffice-cn

    feishu
  ];

  # GitHub CLI tool
  programs.gh = {
    enable = true;
  };

  # allow fontconfig to discover fonts and configurations installed through home.packages
  # Install fonts at system-level, not user-level
  fonts.fontconfig.enable = false;
}
