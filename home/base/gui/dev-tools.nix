{pkgs,config,lib, ...}: let
  d = config.xdg.dataHome;
  c = config.xdg.configHome;
  cache = config.xdg.cacheHome;
in {
  home.packages = with pkgs; [
    mitmproxy # http/https proxy tool
    insomnia # REST client
    wireshark # network analyzer
    dbeaver-bin
    postman
    # IDEs
    #jetbrains.idea-community
    #jetbrains.pycharm-professional
    jetbrains.idea-ultimate
  ];
}
