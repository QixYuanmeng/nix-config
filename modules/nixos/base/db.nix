{ pkgs, config, inputs, lib, ... }:{

    services.mysql = {
      enable = true;
      package = pkgs.mysql80;
    };


    services.redis.servers."redis" = {
      enable = true;
    };
}