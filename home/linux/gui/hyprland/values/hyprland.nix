{ pkgs
, lib
, nur-ryan4yin
, hyprland
, ...
}:
let
  # package = (pkgs.hyprland.overrideAttrs (oldAttrs: {
  #   buildInputs = oldAttrs.buildInputs ++ [ pkgs.hyprgraphics ];
  #   src = pkgs.fetchFromGitHub {
  #     owner = "hyprwm";
  #     repo = "hyprland";
  #     fetchSubmodules = true;
  #     rev = "de3ad245dcbcd42c88e9afc48264bdb8f2356c15";
  #     sha256 = "sha256-Px7iwYO1iUxgDM7GreZRWhFCgD65MoNhQp+nYnhWGM4=";
  #   };
  # }));
  package = hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
in
{
  # NOTE:
  # We have to enable hyprland/i3's systemd user service in home-manager,
  # so that gammastep/wallpaper-switcher's user service can be start correctly!
  # they are all depending on hyprland/i3's user graphical-session
  wayland.windowManager.hyprland = {
    inherit package;
    enable = true;
    settings = {
      source = "${nur-ryan4yin.packages.${pkgs.system}.catppuccin-hyprland}/themes/mocha.conf";
      env = [
        "NIXOS_OZONE_WL,1" # for any ozone-based browser & electron apps to run on wayland
        "MOZ_ENABLE_WAYLAND,1" # for firefox to run on wayland
        "MOZ_WEBRENDER,1"
        # misc
        "_JAVA_AWT_WM_NONREPARENTING,1"
        "QT_WAYLAND_DISABLE_WINDOWDECORATION,1"
        "QT_QPA_PLATFORM,wayland;xcb"
        "SDL_VIDEODRIVER,wayland"
        "GDK_BACKEND,wayland"
        "GSK_RENDERER,gl"
        "QT_IM_MODULE,fcitx"
        "XMODIFIERS,@im=fcitx"
      ];
    };
    extraConfig = builtins.readFile ../conf/hyprland.conf;
    # gammastep/wallpaper-switcher need this to be enabled.
    systemd = {
      enable = true;
      variables = [ "--all" ];
    };
  };

  # NOTE: this executable is used by greetd to start a wayland session when system boot up
  # with such a vendor-no-locking script, we can switch to another wayland compositor without modifying greetd's config in NixOS module
  home.file.".wayland-session" = {
    source = "${package}/bin/Hyprland";
    executable = true;
  };

  # hyprland configs, based on https://github.com/notwidow/hyprland
  xdg.configFile = {
    "hypr/mako" = {
      source = ../conf/mako;
      recursive = true;
    };
    "hypr/scripts" = {
      source = ../conf/scripts;
      recursive = true;
    };
    "hypr/waybar" = {
      source = ../conf/waybar;
      recursive = true;
    };
    "hypr/wlogout" = {
      source = ../conf/wlogout;
      recursive = true;
    };

    # music player - mpd
    "mpd" = {
      source = ../conf/mpd;
      recursive = true;
    };

  };
}
