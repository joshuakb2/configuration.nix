{ username, ... }:

{
  home.username = username;
  home.homeDirectory = "/home/${username}";
  programs.home-manager.enable = true;
  home.stateVersion = "24.11";

  imports = [../home];

  # Host-specific Hyprland settings
  xdg.configFile."hypr/hyprland.host.conf".text = ''
    monitor=DP-3,3440x1440@175,0x0,1
    monitor=HDMI-A-1,3840x2160@60,-3840x0,1
    #monitor=,preferred,auto,auto
  '';

  # HyprPaper wallpapers
  xdg.configFile."hypr/hyprpaper.conf".text = ''
    preload = ~/Pictures/Wallpapers/PinchFilter.png
    wallpaper = ,~/Pictures/Wallpapers/PinchFilter.png
  '';
}
