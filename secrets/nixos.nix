{
  lib,
  config,
  pkgs,
  agenix,
  mysecrets,
  myvars,
  ...
}:
with lib; let
  cfg = config.modules.secrets;

  noaccess = {
    mode = "0000";
    owner = "root";
  };
  high_security = {
    mode = "0500";
    owner = "root";
  };
  user_readable = {
    mode = "0500";
    owner = myvars.username;
  };
in {
  imports = [
    agenix.nixosModules.default
  ];

  options.modules.secrets = {
    desktop.enable = mkEnableOption "NixOS Secrets for Desktops";

    server.network.enable = mkEnableOption "NixOS Secrets for Network Servers";
    server.application.enable = mkEnableOption "NixOS Secrets for Application Servers";
    server.operation.enable = mkEnableOption "NixOS Secrets for Operation Servers(Backup, Monitoring, etc)";
    server.kubernetes.enable = mkEnableOption "NixOS Secrets for Kubernetes";
    server.webserver.enable = mkEnableOption "NixOS Secrets for Web Servers(contains tls cert keys)";
    server.storage.enable = mkEnableOption "NixOS Secrets for HDD Data's LUKS Encryption";

    impermanence.enable = mkEnableOption "whether use impermanence and ephemeral root file system";
  };

  config =
    mkIf (
      cfg.desktop.enable
      || cfg.server.application.enable
      || cfg.server.network.enable
      || cfg.server.operation.enable
      || cfg.server.kubernetes.enable
    ) (mkMerge [
      {
        environment.systemPackages = [
          agenix.packages."${pkgs.system}".default
        ];

        # if you changed this key, you need to regenerate all encrypt files from the decrypt contents!
        age.identityPaths =
          if cfg.impermanence.enable
          then [
            # To decrypt secrets on boot, this key should exists when the system is booting,
            # so we should use the real key file path(prefixed by `/persistent/`) here, instead of the path mounted by impermanence.
            "/persistent/etc/ssh/ssh_host_ed25519_key" # Linux
            "/home/qix/.ssh/qixNix"
          ]
          else [
            "/etc/ssh/ssh_host_ed25519_key"
          ];

        assertions = [
          {
            # This expression should be true to pass the assertion
            assertion =
              !(cfg.desktop.enable
                && (
                  cfg.server.application.enable
                  || cfg.server.network.enable
                  || cfg.server.operation.enable
                  || cfg.server.kubernetes.enable
                ));
            message = "Enable either desktop or server's secrets, not both!";
          }
        ];
      }

      (mkIf cfg.desktop.enable {
        age.secrets = {
          # ---------------------------------------------
          # no one can read/write this file, even root.
          # ---------------------------------------------

          # .age means the decrypted file is still encrypted by age(via a passphrase)
          "qix.age" =
            {
              file = "${mysecrets}/qix.age";
            }
            // noaccess;

          # ---------------------------------------------
          # only root can read this file.
          # ---------------------------------------------

          # "wg-business.conf" =
          #   {
          #     file = "${mysecrets}/wg-business.conf.age";
          #   }
          #   // high_security;

          # # Used only by NixOS Modules
          # # smb-credentials is referenced in /etc/fstab, by ../hosts/ai/cifs-mount.nix
          # "smb-credentials" =
          #   {
          #     file = "${mysecrets}/smb-credentials.age";
          #   }
          #   // high_security;

          # "rclone.conf" =
          #   {
          #     file = "${mysecrets}/rclone.conf.age";
          #   }
          #   // high_security;

          "nix-access-tokens" =
            {
              file = "${mysecrets}/nix-access-tokens.age";
            }
            // high_security;

            "luks.age" = {
            file = "${mysecrets}/luks.age";
            mode = "0400";
            owner = "root";
          };

          # ---------------------------------------------
          # user can read this file.
          # ---------------------------------------------

          "config.yaml" =
            {
              file = "${mysecrets}/config.yaml";
            }
            // user_readable;


            "config.dae" =
            {
              file = "${mysecrets}/config.dae";
            }
            // user_readable;

          # # alias-for-work
          # "alias-for-work.nushell" =
          #   {
          #     file = "${mysecrets}/alias-for-work.nushell.age";
          #   }
          #   // user_readable;

          # "alias-for-work.bash" =
          #   {
          #     file = "${mysecrets}/alias-for-work.bash.age";
          #   }
          #   // user_readable;
        };

        # place secrets in /etc/
        environment.etc = {
          # wireguard config used with `wg-quick up wg-business`
          # "wireguard/wg-business.conf" = {
          #   source = config.age.secrets."wg-business.conf".path;
          # };

          # "agenix/rclone.conf" = {
          #   source = config.age.secrets."rclone.conf".path;
          # };

          # "agenix/ssh-key-romantic" = {
          #   source = config.age.secrets."ssh-key-romantic".path;
          #   mode = "0600";
          #   user = myvars.username;
          # };

          "agenix/qix.age" = {
            source = config.age.secrets."qix.age".path;
            mode = "0000";
          };

          "agenix/luks.age" = {
            source = config.age.secrets."luks.age".path;
            mode = "0400";
            user = "root";
          };

          # The following secrets are used by home-manager modules
          # So we need to make then readable by the user
          # "agenix/alias-for-work.nushell" = {
          #   source = config.age.secrets."alias-for-work.nushell".path;
          #   mode = "0644"; # both the original file and the symlink should be readable and executable by the user
          # };
          # "agenix/alias-for-work.bash" = {
          #   source = config.age.secrets."alias-for-work.bash".path;
          #   mode = "0644"; # both the original file and the symlink should be readable and executable by the user
          # };
        };
      })

      (mkIf cfg.server.network.enable {
        age.secrets = {
          "dae-subscription.dae" =
            {
              file = "${mysecrets}/server/dae-subscription.dae.age";
            }
            // high_security;
        };
      })

      (mkIf cfg.server.storage.enable {
        age.secrets = {
          "hdd-luks-crypt-key" = {
            file = "${mysecrets}/hdd-luks-crypt-key.age";
            mode = "0400";
            owner = "root";
          };
        };

        # place secrets in /etc/
        environment.etc = {
          "agenix/hdd-luks-crypt-key" = {
            source = config.age.secrets."hdd-luks-crypt-key".path;
            mode = "0400";
            user = "root";
          };
        };
      })
    ]);
}