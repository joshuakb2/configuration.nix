{ pkgs, ... }:

{
  # Hyprland config
  wayland.windowManager.hyprland = {
    enable = true;
    package = pkgs.hyprland;
    extraConfig = ''
      source = ./hyprland.local.conf
    '';
  };

  # HyprPaper wallpapers
  xdg.configFile."hypr/hyprpaper.conf".text = ''
    preload = ~/Pictures/Wallpapers/PinchFilter.png
    wallpaper = ,~/Pictures/Wallpapers/PinchFilter.png
  '';
}
