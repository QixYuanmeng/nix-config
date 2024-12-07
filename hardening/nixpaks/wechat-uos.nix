# TODO: wechat-uos is running in FHS sandbox by default, it's problematic
#   to wrap it again via flatpak. We need to find a way to fix it.
#   https://github.com/NixOS/nixpkgs/blob/nixos-unstable/pkgs/by-name/we/wechat-uos/package.nix
# Refer:
# - Flatpak manifest's docs:
#   - https://docs.flatpak.org/en/latest/manifests.html
#   - https://docs.flatpak.org/en/latest/sandbox-permissions.html
# - wechat-uos's flatpak manifest: https://github.com/flathub/com.tencent.WeChat/blob/master/com.tencent.WeChat.yaml
{
  lib,
  pkgs,
  mkNixPak,
  ...
}:
mkNixPak {
  config = {sloth, ...}: {
    app = {
      package = pkgs.wechat-uos;
      binPath = "bin/wechat-uos";
    };
    flatpak.appId = "com.tencent.WeChat";

    imports = [
      ./modules/gui-base.nix
      ./modules/network.nix
    ];

    # list all dbus services:
    #   ls -al /run/current-system/sw/share/dbus-1/services/
    #   ls -al /etc/profiles/per-user/ryan/share/dbus-1/services/
    dbus.policies = {
      "org.gnome.Shell.Screencast" = "talk";
      # System tray icon
      "org.freedesktop.Notifications" = "talk";
      "org.kde.StatusNotifierWatcher" = "talk";
      # File Manager
      "org.freedesktop.FileManager1" = "talk";
      # Uses legacy StatusNotifier implementation
      "org.kde.*" = "own";
    };
    bubblewrap = {
      # To trace all the home files QQ accesses, you can use the following nushell command:
      #   just trace-access wechat-uos
      # See the Justfile in the root of this repository for more information.
      bind.rw = [
        # given the read write permission to the following directories.
        # NOTE: sloth.mkdir is used to create the directory if it does not exist!
        (sloth.mkdir (sloth.concat [sloth.homeDir "/.xwechat"]))
        (sloth.mkdir (sloth.concat [sloth.homeDir "/.xwechat/crashinfo"]))
        (sloth.mkdir (sloth.concat [sloth.homeDir "/.xwechat/crashinfo/attachments"]))
        (sloth.mkdir (sloth.concat [sloth.xdgDocumentsDir "/xwechat_files"]))
        (sloth.mkdir (sloth.concat [sloth.xdgDocumentsDir "/WeChat_Data/"]))
        (sloth.mkdir (sloth.concat [sloth.xdgDownloadDir "/WeChat"]))
      ];
      bind.ro = [
        "/sys"
        "/etc/machine-id"
        "/etc/localtime"
        "/etc/passwd"

        # Certificates. Required for SSL connections. Kind of optional
        "/etc/ssl/certs/ca-bundle.crt"
        "/etc/ssl/certs/ca-certificates.crt"
        "/etc/pki/tls/certs/ca-bundle.crt"

      ];
      sockets = {
        x11 = false;
        wayland = true;
        pipewire = true;
      };
      bind.dev = [
        "/dev/shm" # Shared Memory
        "/dev/video0"
        "/dev/video1"
      ];
      tmpfs = [
        "/tmp"
      ];
      env = {
        # Hidpi scale
        "QT_AUTO_SCREEN_SCALE_FACTOR" = "1";
        # Only supports xcb
        "QT_QPA_PLATFORM" = "kcb";
        IBUS_USE_PORTAL = "1";
                XDG_DATA_DIRS = lib.mkForce (lib.makeSearchPath "share" (with pkgs; [
                  adw-gtk3
                  tela-icon-theme
                  shared-mime-info
        ]));
        XCURSOR_PATH = lib.mkForce (lib.concatStringsSep ":" (with pkgs; [
          "${tela-icon-theme}/share/icons"
          "${tela-icon-theme}/share/pixmaps"
          "${simp1e-cursors}/share/icons"
          "${simp1e-cursors}/share/pixmaps"
        ]));
      };
    };
  };
}