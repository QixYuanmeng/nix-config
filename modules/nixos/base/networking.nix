{
  pkgs,
  pkgs-unstable,
  nixyDomains,
  daeuniverse,
  config,
  ...
}:{
  # Network discovery, mDNS
  # With this enabled, you can access your machine at <hostname>.local
  # it's more convenient than using the IP address.
  # https://avahi.org/
  # services.avahi = {
  #   enable = true;
  #   nssmdns4 = true;
  #   publish = {
  #     enable = true;
  #     domain = true;
  #     userServices = true;
  #   };
  # };

  # Use an NTP server located in the mainland of China to synchronize the system time
  networking.timeServers = [
    "ntp.aliyun.com" # Aliyun NTP Server
    "ntp.tencent.com" # Tencent NTP Server
  ];


  # daeuniverse.url = "github:daeuniverse/flake.nix";
  # add the module to the configuration
  imports = [
    daeuniverse.nixosModules.dae
    daeuniverse.nixosModules.daed
  ];

  services.daed = {

    enable = true;
    package = pkgs-unstable.daed;
    assetsPaths = [
          "${nixyDomains}/assets"
          "${pkgs.v2ray-geoip}/share/v2ray/geoip.dat"
          "${pkgs.v2ray-domain-list-community}/share/v2ray/geosite.dat"
        ];
    openFirewall = {
      enable = true;
      port = 12345;
    };
  };
}
