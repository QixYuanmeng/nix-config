{ pkgs
, nix-gaming
, ...
}: {
  home.packages = with pkgs; [
    # nix-gaming.packages.${pkgs.system}.osu-laser-bin
    gamescope # SteamOS session compositing window manager
    (prismlauncher.overrideAttrs (oldAttrs: {
      postInstall = oldAttrs.postInstall or "" + ''
        # Create a wrapper script
        cat > $out/bin/prismlauncher-nvidia-offload <<EOF
        #!/bin/sh
        export __NV_PRIME_RENDER_OFFLOAD=1
        export __VK_LAYER_NV_optimus=NVIDIA_only
        export __GLX_VENDOR_LIBRARY_NAME=nvidia
        exec $out/bin/prismlauncher "\$@"
        EOF
        chmod +x $out/bin/prismlauncher-nvidia-offload

        # Replace the original prismlauncher binary with the wrapper
        mv $out/bin/prismlauncher $out/bin/prismlauncher-original
        ln -s $out/bin/prismlauncher-nvidia-offload $out/bin/prismlauncher
      '';
    })
    )
    winetricks # A script to install DLLs needed to work around problems in Wine
  ];
}
