{ pkgs, username, hyprgrass, ... }:

{
  home.username = username;
  home.homeDirectory = "/home/${username}";
  programs.home-manager.enable = true;
  home.stateVersion = "24.11";

  imports = [../home];

  # Hyprland plugins
  wayland.windowManager.hyprland.plugins = [
    # hyprgrass doesn't build right now
    # hyprgrass.packages.${pkgs.system}.default
  ];

  # Host-specific Hyprland settings
  xdg.configFile."hypr/hyprland.host.conf".text = let
    primaryMonitor = "eDP-1,1920x1080@60,0x0,1";
  in ''
    # See https://wiki.hyprland.org/Configuring/Monitors/
    monitor=${primaryMonitor}
    # monitor=HDMI-A-1,3440x1440@172,0x0,1

    bind = $mainMod, F, exec, hyprctl keyword monitor ${primaryMonitor},transform,0
    bind = $mainMod ALT, F, exec, hyprctl keyword monitor ${primaryMonitor},transform,2
  '';

  hyprland.displayToMirror = "eDP-1";

  # HyprPaper wallpapers
  xdg.configFile."hypr/hyprpaper.conf".text = ''
    preload = ~/Pictures/Wallpapers/PinchFilter.png
    wallpaper = ,~/Pictures/Wallpapers/PinchFilter.png
  '';
}
