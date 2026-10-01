{
  pkgs,
  config,
  lib,
  ...
}:

let
  cfg = config.desktops;
  listNoConcatOf =
    type:
    lib.types.listOf type
    // {
      merge =
        _: defs:
        if builtins.length defs == 0 then [ ] else (builtins.elemAt defs (builtins.length defs - 1)).value;
    };
in
{
  options.desktops = {
    enable = lib.mkOption {
      type = listNoConcatOf (
        lib.types.enum [
          "hyprland"
          "gnome"
          "plasma"
          "cosmic"
          "cinnamon"
          "niri"
        ]
      );
      default = [
        "hyprland"
        "niri"
      ];
      description = "The list of desktop environments to provide";
    };

    specialisations = {
      gnome = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Build a specialisation that offers the GNOME desktop.";
      };

      plasma = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Build a specialisation that offers the KDE Plasma 6 desktop.";
      };

      cosmic = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Build a specialisation that offers the Cosmic desktop.";
      };

      cinnamon = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Build a specialisation that offers the Cinnamon desktop.";
      };
    };

    gdmExtensions = lib.mkOption {
      type = lib.types.listOf lib.types.package;
      default = [ ];
      description = "GNOME extensions to install in the GDM user directory";
    };
  };

  config =
    let
      # Ordered by preference
      desktops = [
        "hyprland"
        "niri"
        "cosmic"
        "gnome"
        "plasma"
        "cinnamon"
      ];
      enabledDesktops = builtins.filter (x: builtins.elem x cfg.enable) desktops;
      nonCosmicEnabledDesktops = builtins.filter (x: x != "cosmic") enabledDesktops;
      hyprland = builtins.elem "hyprland" enabledDesktops;
      gnome = builtins.elem "gnome" enabledDesktops;
      plasma = builtins.elem "plasma" enabledDesktops;
      cosmic = builtins.elem "cosmic" enabledDesktops;
      cinnamon = builtins.elem "cinnamon" enabledDesktops;
      niri = builtins.elem "niri" enabledDesktops;
    in
    {
      warnings =
        let
          cosmicAndOthers = cosmic && builtins.length enabledDesktops > 1;
        in
        lib.mkMerge [
          (lib.mkIf cosmicAndOthers [
            "You have enabled Cosmic and other desktops at the same time (${lib.concatStringsSep ", " nonCosmicEnabledDesktops}). Cosmic greeter will be used instead of GDM."
          ])
        ];

      services.displayManager.gdm.enable = !cosmic;
      services.displayManager.cosmic-greeter.enable = cosmic;
      services.desktopManager.cosmic.enable = cosmic;
      services.desktopManager.gnome.enable = gnome;
      services.desktopManager.plasma6.enable = plasma;
      services.xserver.desktopManager.cinnamon.enable = cinnamon;
      programs.hyprland.enable = hyprland;
      programs.niri.enable = niri;
      # useNautilus breaks the file picker.
      # Specifically, when useNautilus is true, we use the GNOME portal instead of the GTK portal.
      # But for whatever reason, the GNOME portal hangs.
      programs.niri.useNautilus = false;
      environment.systemPackages =
        with pkgs;
        lib.mkMerge [
          (lib.mkIf niri [
            awww
            xwayland-satellite
          ])
        ];
      services.displayManager.defaultSession = builtins.elemAt enabledDesktops 0;

      xdg.portal =
        let
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
          niriXdg = lib.mkForce {
            enable = true;
            xdgOpenUsePortal = true;
            extraPortals = [ pkgs.xdg-desktop-portal-hyprland ];
            config.niri.default = [
              "gtk"
              "hyprland"
            ];
          };
        in
        lib.mkMerge [
          (lib.mkIf plasma plasmaXdg)
          (lib.mkIf cosmic cosmicXdg)
          (lib.mkIf niri niriXdg)
        ];

      # environment.pathsToLink = lib.mkIf cosmic [ "/share/applications" "/share/xdg-desktop-portal" ];

      # Make sure GDM can find extensions in its user's home folder
      systemd.tmpfiles.rules =
        let
          toRule =
            pkg:
            let
              uuid = pkg.extensionUuid;
            in
            "L+ /run/gdm/.local/share/gnome-shell/extensions/${uuid} - gdm gdm - ${pkg}/share/gnome-shell/extensions/${uuid}";
        in
        if builtins.length cfg.gdmExtensions > 0 then
          [
            "d /run/gdm/ - gdm gdm - -"
            "d /run/gdm/.local - gdm gdm - -"
            "d /run/gdm/.local/share - gdm gdm - -"
            "d /run/gdm/.local/share/gnome-shell - gdm gdm - -"
            "d /run/gdm/.local/share/gnome-shell/extensions - gdm gdm - -"
          ]
          ++ map toRule cfg.gdmExtensions
        else
          [ ];

      specialisation = lib.mkMerge [
        (lib.mkIf cfg.specialisations.gnome { gnome.configuration.desktops.enable = [ "gnome" ]; })
        (lib.mkIf cfg.specialisations.plasma { plasma.configuration.desktops.enable = [ "plasma" ]; })
        (lib.mkIf cfg.specialisations.cosmic { cosmic.configuration.desktops.enable = [ "cosmic" ]; })
        (lib.mkIf cfg.specialisations.cinnamon { cinnamon.configuration.desktops.enable = [ "cinnamon" ]; })
      ];
    };
}
