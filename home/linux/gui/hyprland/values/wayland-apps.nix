{ pkgs
, pkgs-unstable
, nur-ryan4yin
, config
, lib
, ...
}: {
  # refer to https://codeberg.org/dnkl/foot/src/branch/master/foot.ini
  xdg.configFile."foot/foot.ini".text =
    ''
      [main]
      dpi-aware=yes
      font=JetBrainsMono Nerd Font:size=13
      shell=${pkgs.bash}/bin/bash --login -c 'nu --login --interactive'
      term=foot
      initial-window-size-pixels=3840x2160
      initial-window-mode=windowed
      pad=0x0                             # optionally append 'center'
      resize-delay-ms=10

      [mouse]
      hide-when-typing=yes
    ''
    + (builtins.readFile "${nur-ryan4yin.packages.${pkgs.system}.catppuccin-foot}/catppuccin-mocha.conf");

  home.packages = [
    # pkgs.firefox-wayland
    pkgs.nixpaks.firefox
    pkgs.nixpaks.firefox-desktop-item

    pkgs.nixpkgs-fmt
  ];

  services.flameshot = let
    flameshotGrim = pkgs-unstable.flameshot.overrideAttrs (oldAttrs: {
    src = pkgs.fetchFromGitHub {
      owner = "flameshot-org";
      repo = "flameshot";
      rev = "3fafcf4aa9ae3d620ff691cba3a1a2195d592914";
      sha256 = "sha256-lt7RIe1KFOPnBpVZf7oZMOQOyOAf65ByxaHCNDqbTpk=";
    };
    cmakeFlags =  [
      (lib.cmakeBool "DISABLE_UPDATE_CHECKER" true)
      (lib.cmakeBool "USE_MONOCHROME_ICON" true)
    ]
    ++  [
      (lib.cmakeBool "USE_WAYLAND_CLIPBOARD" true)
      (lib.cmakeBool "USE_WAYLAND_GRIM" true)
    ];
    buildInputs = with pkgs;[ libsForQt5.qtbase libsForQt5.kguiaddons ];
    nativeBuildInputs =
    with pkgs;[
      cmake
      libsForQt5.qttools
      libsForQt5.qtsvg
      libsForQt5.wrapQtAppsHook
      makeBinaryWrapper
    ];
  });
  in
  {
    enable = true;
    package = flameshotGrim;
  };

  programs = {
    # a wayland only terminal emulator
    foot = {
      enable = true;
      # foot can also be run in a server mode. In this mode, one process hosts multiple windows.
      # All Wayland communication, VT parsing and rendering is done in the server process.
      # New windows are opened by running footclient, which remains running until the terminal window is closed.
      #
      # Advantages to run foot in server mode including reduced memory footprint and startup time.
      # The downside is a performance penalty. If one window is very busy with, for example, producing output,
      # then other windows will suffer. Also, should the server process crash, all windows will be gone.
      server.enable = true;
    };

    # source code: https://github.com/nix-community/home-manager/blob/master/modules/programs/chromium.nix
    google-chrome = {
      enable = true;

      # https://wiki.archlinux.org/title/Chromium#Native_Wayland_support
      commandLineArgs = [
        "--ozone-platform-hint=auto"
        "--ozone-platform=wayland"
        #"--disable-gpu"
        # make it use GTK_IM_MODULE if it runs with Gtk4, so fcitx5 can work with it.
        # (only supported by chromium/chrome at this time, not electron)
        #"--gtk-version=4"
        # make it use text-input-v1, which works for kwin 5.27 and weston
        "--enable-wayland-ime"

        # enable hardware acceleration - vulkan api
        # "--enable-features=Vulkan"
      ];
    };

    vscode = {
      enable = true;
      # let vscode sync and update its configuration & extensions across devices, using github account.
      userSettings = { };
      package =
        (pkgs.vscode.override
          {
            isInsiders = false;
            # https://wiki.archlinux.org/title/Wayland#Electron
            commandLineArgs = [
              "--ozone-platform-hint=auto"
              "--ozone-platform=wayland"
              # make it use GTK_IM_MODULE if it runs with Gtk4, so fcitx5 can work with it.
              # (only supported by chromium/chrome at this time, not electron)
              #"--gtk-version=4"
              # make it use text-input-v1, which works for kwin 5.27 and weston
              "--enable-wayland-ime"
              #"--disable-gpu"
              # TODO: fix https://github.com/microsoft/vscode/issues/187436
              # still not works...
              "--password-store=gnome" # use gnome-keyring as password store
            ];
          });
    };
  };
}
