{ pkgs
, pkgs-unstable
, lib
, nur-linyinfeng
, ...
}: {
  home.packages = with pkgs; [
    # GUI apps
    # e-book viewer(.epub/.mobi/...)
    # do not support .pdf
    foliate

    # instant messaging
    telegram-desktop
    # discord # update too frequently, use the web version instead

    # remote desktop(rdp connect)
    remmina
    freerdp # required by remmina

    # misc
    ventoy # multi-boot usb creator

    # my custom hardened packages
    (pkgs.qq.override
    {
      # fix fcitx5 input method
      commandLineArgs = lib.concatStringsSep " " [
        "--ozone-platform-hint=auto"
        "--ozone-platform=wayland"
        "--enable-wayland-ime"
      ];
    })
    #pkgs.nixpaks.qq-desktop-item

    #wechat-uos
    pkgs.nixpaks.wechat-uos
    #pkgs.nixpaks.wechat-uos-desktop-item

    # nur-linyinfeng.packages.${pkgs.system}.wemeet

    feishu

    rustdesk
  ];

  # GitHub CLI tool
  programs.gh = {
    enable = true;
  };

  # allow fontconfig to discover fonts and configurations installed through home.packages
  # Install fonts at system-level, not user-level
  fonts.fontconfig.enable = false;
}
