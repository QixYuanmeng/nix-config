{pkgs-unstable, nur-qixyuanmeng, pkgs, config, ...}: {
  # ===============================================================================================
  # for Nvidia GPU
  # ===============================================================================================

  # https://wiki.hyprland.org/Nvidia/
  boot.kernelParams = [
    # Since NVIDIA does not load kernel mode setting by default,
    # enabling it is required to make Wayland compositors function properly.
    "modprobe.blacklist=nouveau"
    "ec_sys.write_support=1"
    "msr.allow_writes=on"
    #"nvidia.NVreg_PreserveVideoMemoryAllocations=1"
    #"nvidia-drm.fbdev=1"
  ];
  services.xserver.videoDrivers = ["nvidia"]; # will install nvidia-vaapi-driver by default
  services.thermald.enable = true;
  hardware.nvidia = {
    open = false;
    # Optionally, you may need to select the appropriate driver version for your specific GPU.
    # https://github.com/NixOS/nixpkgs/blob/nixos-unstable/pkgs/os-specific/linux/nvidia-x11/default.nix
    # package = config.boot.kernelPackages.nvidiaPackages.stable;
    package = config.boot.kernelPackages.nvidiaPackages.beta;
    # required by most wayland compositors!
    modesetting.enable = false;
    powerManagement.enable = true;
    powerManagement.finegrained = true;
    nvidiaPersistenced = true;
  };

	hardware.nvidia.prime = {
    sync.enable = false;
		offload = {
			enable = true;
			enableOffloadCmd = true;
		};
		# Make sure to use the correct Bus ID values for your system!
		intelBusId = "PCI:0:2:0";
		nvidiaBusId = "PCI:1:0:0";
                # amdgpuBusId = "PCI:54:0:0"; For AMD GPU
	};

  hardware.nvidia-container-toolkit.enable = true;
  hardware.graphics = {
    enable = true;
    # needed by nvidia-docker
    enable32Bit = true;
  };
  # disable cudasupport before this issue get fixed:
  # https://github.com/NixOS/nixpkgs/issues/338315
  nixpkgs.config.cudaSupport = false;
  nixpkgs.overlays = [
    (_: super: {
      blender = super.blender.override {
        # https://nixos.org/manual/nixpkgs/unstable/#opt-cudaSupport
        cudaSupport = true;
        waylandSupport = true;
      };
      myRepo = nur-qixyuanmeng.packages."${pkgs.system}";

      # ffmpeg-full = super.ffmpeg-full.override {
      #   withNvcodec = true;
      # };
    })
  ];
}
