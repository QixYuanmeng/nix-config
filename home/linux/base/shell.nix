{
  config,
  myvars,
  ...
}: let
  d = config.xdg.dataHome;
  c = config.xdg.configHome;
  cache = config.xdg.cacheHome;
in rec {
  home.homeDirectory = "/home/${myvars.username}";

  # environment variables that always set at login
  home.sessionVariables = {
    # clean up ~
    LESSHISTFILE = cache + "/less/history";
    LESSKEY = c + "/less/lesskey";
    WINEPREFIX = d + "/wine";
    GTK_IM_MODULE = "fcitx";
    LANG = "zh_CN.UTF-8";

    # set this variable make i3 failed to start
    # related issue:
    #   https://github.com/sddm/sddm/issues/871
    # XAUTHORITY = "$XDG_RUNTIME_DIR/Xauthority";

    # set default applications
    BROWSER = "microsoft-edge";
    TERM = "alacritty";
    TERMINAL = "alacritty";

    # enable scrolling in git diff
    DELTA_PAGER = "less -R";
  };
}
