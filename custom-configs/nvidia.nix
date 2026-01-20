{ pkgs, config, lib, ... }:

{
  options = {
    nvidiaTweaks = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable this if you have an NVIDIA GPU";
    };
    nvidiaPascal = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Whether the installed GPU has the Pascal architecture";
    };
  };

  config = lib.mkIf config.nvidiaTweaks {
    boot.initrd.availableKernelModules = [ "nvidia_drm" "nvidia_modeset" "nvidia" "nvidia_uvm" ];

    hardware.graphics = {
      enable = true;
      # Disabled because I'm not sure if this is still needed or not? Does Chromium video decoding work without this?
      # extraPackages = [pkgs.libvdpau-va-gl]; # Necessary for Chromium hardware accelerated video decoding
      enable32Bit = true;
    };

    services.xserver.videoDrivers = ["nvidia"];

    hardware.nvidia = {
      # Joshua-PC has a GTX 1070 Ti which is no longer supported in 590 and above.
      package = lib.mkMerge [
        (lib.mkIf config.nvidiaPascal config.boot.kernelPackages.nvidiaPackages.stable)
        (lib.mkIf (!config.nvidiaPascal) config.boot.kernelPackages.nvidiaPackages.latest)
      ];
      modesetting.enable = true;
      powerManagement.enable = false;
      powerManagement.finegrained = false;
      open = false;
    };
  };
}
