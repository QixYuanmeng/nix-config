{ pkgs-unstable, nur-qixyuanmeng, auto-cpufreq, nbfc-linux, pkgs, config, ... }:
let
  command = "bin/nbfc_service --config-file /etc/nbfc.json";
in
{
  config.environment.systemPackages = with pkgs; [
    # if you are on stable uncomment the next line
    #nbfc-linux.packages.x86_64-linux.default
    # if you are on unstable uncomment the next line
    #nbfc-linux
  ];
  config.systemd.services.nbfc_service = {
    enable = false;
    description = "NoteBook FanControl service";
    serviceConfig.Type = "simple";
    path = [ pkgs.kmod ];

    # if you are on stable uncomment the next line
    script = "${nbfc-linux.packages.x86_64-linux.default}/${command}";
    # if you are on unstable uncomment the next line
    #script = "${pkgs.nbfc-linux.packages}/${command}";

    wantedBy = [ "multi-user.target" ];
  };
  config.environment.etc."nbfc.json".source = ./nbfc.json;
}
