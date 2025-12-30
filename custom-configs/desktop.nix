{ pkgs, config, lib, ... }:

let cfg = config.desktop;
in {
  options.desktop = {
    hyprland = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Whether to enable Hyprland";
    };

    gnome = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Whether to enable GNOME";
    };

    plasma = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Whether to use KDE Plasma 6 in Wayland";
    };

    cosmic = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Whether to use Cosmic in Wayland";
    };

    cinnamon = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Whether to use Cinnamon in Wayland";
    };

    gdmExtensions = lib.mkOption {
      type = lib.types.listOf lib.types.package;
      default = [];
      description = "GNOME extensions to install in the GDM user directory";
    };
  };

  config = let
    # Ordered by preference
    desktops = ["hyprland" "cosmic" "gnome" "plasma" "cinnamon"];
    nameIfEnabled = name: if cfg.${name} then name else null;
    enabledDesktops = builtins.filter (x: x != null) (map nameIfEnabled desktops);
    nonCosmicEnabledDesktops = builtins.filter (x: x != "cosmic") enabledDesktops;
  in {
    warnings = let
      cosmicAndOthers = cfg.cosmic && builtins.length enabledDesktops > 1;
    in lib.mkMerge [
      (lib.mkIf cosmicAndOthers ["You have enabled Cosmic and other desktops at the same time (${lib.concatStringsSep ", " nonCosmicEnabledDesktops}). Cosmic greeter will be used instead of GDM."])
    ];

    services.displayManager.gdm.enable = !cfg.cosmic;
    services.displayManager.cosmic-greeter.enable = cfg.cosmic;
    services.desktopManager.cosmic.enable = cfg.cosmic;
    services.desktopManager.gnome.enable = cfg.gnome;
    services.desktopManager.plasma6.enable = cfg.plasma;
    services.xserver.desktopManager.cinnamon.enable = cfg.cinnamon;
    programs.hyprland.enable = cfg.hyprland;
    services.displayManager.defaultSession = builtins.elemAt enabledDesktops 0;

    xdg.portal = let
      plasmaXdg = {
        enable = true;
        xdgOpenUsePortal = true;
        extraPortals = [ pkgs.kdePackages.xdg-desktop-portal-kde ];
        config.common.default = [ "kde" ];
      };
      cosmicXdg = {
        enable = true;
        xdgOpenUsePortal = true;
        extraPortals = [ pkgs.xdg-desktop-portal-cosmic ];
        config.common.default = [ "cosmic" ];
      };

    in lib.mkMerge [
      (lib.mkIf cfg.plasma plasmaXdg)
      (lib.mkIf cfg.cosmic cosmicXdg)
    ];

    # environment.pathsToLink = lib.mkIf cfg.cosmic [ "/share/applications" "/share/xdg-desktop-portal" ];

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
          builtins.length cfg.gdmExtensions > 0
        then
          [
            "d /run/gdm/ - gdm gdm - -"
            "d /run/gdm/.local - gdm gdm - -"
            "d /run/gdm/.local/share - gdm gdm - -"
            "d /run/gdm/.local/share/gnome-shell - gdm gdm - -"
            "d /run/gdm/.local/share/gnome-shell/extensions - gdm gdm - -"
          ] ++ builtins.map toRule cfg.gdmExtensions
        else
          [];

  };
}
