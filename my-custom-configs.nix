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

    programs.kpuinput.package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.kpuinput;
      description = "KPUInput package";
    };
    programs.kpuinput.enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Build kpuinput library for KeePass during activation";
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

    environment.systemPackages = if config.programs.kpuinput.enable then [
      config.programs.kpuinput.package
    ] else [];

    users.groups.uinputg = lib.mkIf config.programs.kpuinput.enable {
      members = [config.myUserName];
    };

    services.udev.packages = lib.mkIf config.programs.kpuinput.enable [
      (pkgs.stdenv.mkDerivation {
        name = "kpuinput-udev-rules";
        src = pkgs.writeTextFile rec {
          name = "kpuinput.rules";
          text = ''
            KERNEL=="uinput", GROUP="uinputg", MODE="0660", OPTIONS+="static_node=uinput"
          '';
          destination = "/lib/" + name;
        };
        dontBuild = true;
        installPhase = ''
          mkdir -p $out/lib/udev/rules.d
          cp lib/kpuinput.rules $out/lib/udev/rules.d/89-uinput-u.rules
        '';
      })
    ];

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
