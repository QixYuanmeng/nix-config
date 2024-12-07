{ pkgs-unstable, nur-qixyuanmeng, auto-cpufreq, nbfc-linux, pkgs, config, ... }:
let
  command = "bin/nbfc_service --config-file /etc/nbfc.json";
in
{
  imports = [
    auto-cpufreq.nixosModules.default
  ];

  config.environment.systemPackages = with pkgs; [
    # if you are on stable uncomment the next line
    nbfc-linux.packages.x86_64-linux.default
    # if you are on unstable uncomment the next line
    #pkgs-unstable.auto-cpufreq
    # nbfc-linux
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

  config.programs.auto-cpufreq.enable = true;
  # optionally, you can configure your auto-cpufreq settings, if you have any
  config.programs.auto-cpufreq.settings = {
    charger = {
      governor = "powersave";
      turbo = "auto";
    };

    battery = {
      governor = "powersave";
      turbo = "false";
    };
  };
}
