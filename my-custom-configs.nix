{ pkgs, config, lib, ... }:
{
  options = {
    usePipeWire = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Whether to use PipeWire or Pulse";
    };

    useWayland = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Whether to use Wayland or X.org";
    };

    useGnome = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Whether to use GNOME in Wayland instead of Hyprland";
    };

    useGrub = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Whether to use the GRUB or systemd bootloader";
    };

    nvidiaTweaks = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable this if you have an NVIDIA GPU";
    };

    myUserName = lib.mkOption {
      type = lib.types.str;
      description = "The username for the primary user account (joshua or jbaker)";
    };
  };

  config = {
    services.pipewire = lib.mkIf config.usePipeWire {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
    };

    # Enable sound (ALSA-based, includes pulseaudio)
    sound.enable = !config.usePipeWire;
    hardware.pulseaudio.enable = !config.usePipeWire;

    services.xserver.displayManager.gdm.wayland = config.useWayland;
    services.xserver.desktopManager.gnome.enable = !config.useWayland || config.useGnome;
    services.xserver.displayManager.defaultSession = lib.mkIf (config.useWayland && config.useGnome) "gnome";
    programs = {
      hyprland.enable = config.useWayland && !config.useGnome;
    };
    # services.desktopManager.plasma6.enable = config.useWayland;

    boot.loader = {
      grub = lib.mkIf config.useGrub {
        enable = true;
        device = "nodev";
        efiSupport = true;
        useOSProber = true;
      };
      systemd-boot.enable = !config.useGrub;
    };

    # ============================
    # NVIDIA TWEAKS
    # ============================

    # Needed for suspend to work correctly, I'm told by Hyprland
    boot.kernelParams = lib.mkIf config.nvidiaTweaks [
      "nvidia.NVreg_PreserveVideoMemoryAllocations=1"
      "nvidia_drm.fbdev=1" # Without this, TTY framebuffers don't work (Ctrl-Alt-Fn)
    ];

    hardware.opengl = lib.mkIf config.nvidiaTweaks {
      enable = true;
      extraPackages = [pkgs.libvdpau-va-gl];
      driSupport = true;
      driSupport32Bit = true;
    };

    services.xserver.videoDrivers = lib.mkIf config.nvidiaTweaks ["nvidia"];

    hardware.nvidia = lib.mkIf config.nvidiaTweaks {
      modesetting.enable = true;
      powerManagement.enable = false;
      powerManagement.finegrained = false;
      open = false;
      nvidiaSettings = true;
      package = config.boot.kernelPackages.nvidiaPackages.stable;
    };

    environment.variables = lib.mkIf config.nvidiaTweaks {
      VDPAU_DRIVER = "va_gl";
      LIBVA_DRIVER_NAME = "nvidia";
    };


    security.sudo.extraRules = [{
      users = [config.myUserName];
      commands = [{
        command = "ALL";
        options = ["NOPASSWD"];
      }];
    }];
  };
}
