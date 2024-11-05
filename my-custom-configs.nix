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

    gdmExtensions = lib.mkOption {
      type = lib.types.listOf lib.types.package;
      default = [];
      description = "GNOME extensions to install in the GDM user directory";
    };

    usePlasma = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Whether to use KDE Plasma 6 in Wayland instead of Hyprland";
    };

    useCinnamon = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Whether to use Cinnamon in Wayland instead of Hyprland";
    };

    useGrub = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Whether to use the GRUB or systemd bootloader";
    };

    josh.rook-row.enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Whether to include my rook-row script and completions";
    };

    josh.operator-mono.enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Whether to include my operator mono fonts";
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
    hardware.pulseaudio.enable = !config.usePipeWire;

    services.xserver.displayManager.gdm.wayland = config.useWayland;
    services.xserver.desktopManager.gnome.enable = !config.useWayland || config.useGnome;
    services.desktopManager.plasma6.enable = config.useWayland && config.usePlasma;
    services.xserver.desktopManager.cinnamon.enable = config.useWayland && config.useCinnamon;
    services.displayManager.defaultSession = lib.mkMerge [
      (lib.mkIf (config.useWayland && config.useGnome) "gnome")
      (lib.mkIf (config.useWayland && config.useCinnamon) "cinnamon")
    ];
    programs = {
      hyprland.enable = config.useWayland && !config.useGnome;
    };

    xdg.portal = lib.mkIf config.usePlasma {
      enable = true;
      xdgOpenUsePortal = true;
      extraPortals = [pkgs.xdg-desktop-portal-kde];
      config.common.default = ["kde"];
    };

    boot.loader = {
      grub = lib.mkIf config.useGrub {
        enable = true;
        device = "nodev";
        efiSupport = true;
        useOSProber = true;
        default = "saved";
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

    hardware.graphics = lib.mkIf config.nvidiaTweaks {
      enable = true;
      extraPackages = [pkgs.libvdpau-va-gl];
      enable32Bit = true;
    };

    services.xserver.videoDrivers = lib.mkIf config.nvidiaTweaks ["nvidia"];

    hardware.nvidia = lib.mkIf config.nvidiaTweaks {
      modesetting.enable = true;
      powerManagement.enable = false;
      powerManagement.finegrained = false;
      open = false;
    };

    environment.variables = lib.mkIf config.nvidiaTweaks {
      VDPAU_DRIVER = "va_gl";
      LIBVA_DRIVER_NAME = "nvidia";
    };

    users.users."${config.myUserName}".packages = lib.mkIf config.josh.rook-row.enable [pkgs.rook-row];

    security.sudo.extraRules = [{
      users = [config.myUserName];
      commands = [{
        command = "ALL";
        options = ["NOPASSWD"];
      }];
    }];

    fonts.packages = lib.mkIf config.josh.operator-mono.enable [pkgs.operator-mono-font];

    # Make sure GDM can find extensions in its user's home folder
    systemd.tmpfiles.rules =
      let
        toRule = pkg:
          let
            uuid = pkg.extensionUuid;
          in
            "L+ /run/gdm/.local/share/gnome-shell/extensions/${uuid} - gdm gdm - ${pkg}/share/gnome-shell/extensions/${uuid}";
      in
        if
          builtins.length config.gdmExtensions > 0
        then
          [
            "d /run/gdm/ - gdm gdm - -"
            "d /run/gdm/.local - gdm gdm - -"
            "d /run/gdm/.local/share - gdm gdm - -"
            "d /run/gdm/.local/share/gnome-shell - gdm gdm - -"
            "d /run/gdm/.local/share/gnome-shell/extensions - gdm gdm - -"
          ] ++ builtins.map toRule config.gdmExtensions
        else
          [];

    programs.dconf.profiles.gdm.databases = [{
      settings."org/gnome/shell".enabled-extensions =
        let
          getUuid = pkg: pkg.extensionUuid;
        in
          builtins.map getUuid config.gdmExtensions;
    }];
  };
}
