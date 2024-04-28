_: {
  # Network discovery, mDNS
  # With this enabled, you can access your machine at <hostname>.local
  # it's more convenient than using the IP address.
  # https://avahi.org/
  services.avahi = {
    enable = true;
    3nssmdns4 = true;
    publish = {
      enable = true;
      domain = true;
      userServices = true;
    };
  };
}
