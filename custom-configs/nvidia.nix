{ pkgs, config, lib, ... }:

{
  options = {
    nvidiaTweaks = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable this if you have an NVIDIA GPU";
    };
  };

  config = {
    # Needed for suspend to work correctly, I'm told by Hyprland
    boot.kernelParams = lib.mkIf config.nvidiaTweaks [
      "nvidia.NVreg_PreserveVideoMemoryAllocations=1"
      "nvidia_drm.fbdev=1" # Without this, TTY framebuffers don't work (Ctrl-Alt-Fn)
    ];

    hardware.graphics = lib.mkIf config.nvidiaTweaks {
      enable = true;
      extraPackages = [pkgs.libvdpau-va-gl];
      enable32Bit = true;
    };

    services.xserver.videoDrivers = lib.mkIf config.nvidiaTweaks ["nvidia"];

    hardware.nvidia = lib.mkIf config.nvidiaTweaks {
      package = config.boot.kernelPackages.nvidiaPackages.latest;
      modesetting.enable = true;
      powerManagement.enable = false;
      powerManagement.finegrained = false;
      open = false;
    };

    environment.variables = lib.mkIf config.nvidiaTweaks {
      VDPAU_DRIVER = "va_gl";
      LIBVA_DRIVER_NAME = "nvidia";
    };
  };
}
