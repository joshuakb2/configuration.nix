{ pkgs, config, lib, ... }:

{
  options = {
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
  };

  config = {
    services.displayManager.gdm.wayland = config.useWayland;
    services.desktopManager.gnome.enable = !config.useWayland || config.useGnome;
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
