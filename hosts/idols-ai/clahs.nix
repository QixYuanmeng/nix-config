{config,...}
:
{
  services.mihomo = {
    enable = true;
    tunMode = true;
    configFile = config.age.secrets."config.yaml".path;
    webui = pkgs.metacubexd;
  };
  systemd.services.mihomo.serviceConfig.ExecStartPre = [
      "${pkgs.coreutils}/bin/ln -sf ${pkgs.v2ray-geoip}/share/v2ray/geoip.dat /var/lib/private/mihomo/GeoIP.dat"
      "${pkgs.coreutils}/bin/ln -sf ${pkgs.v2ray-domain-list-community}/share/v2ray/geosite.dat /var/lib/private/mihomo/GeoSite.dat"
    ];

  networking.proxy.default = "http://127.0.0.1:7890";
  networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";
  networking.firewall.allowedTCPPorts = [9090];
}