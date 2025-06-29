{ username, ... }:

{
  home.username = username;
  home.homeDirectory = "/home/${username}";
  programs.home-manager.enable = true;
  home.stateVersion = "24.11";

  imports = [../home];

  # Host-specific Hyprland settings
  xdg.configFile."hypr/hyprland.host.conf".text = ''
    # monitor=DP-3,3440x1440@144,0x0,1,bitdepth,10,cm,hdr,sdrbrightness,1.0,sdrsaturation,1.0
    monitor=DP-3,3440x1440@144,0x0,1
    monitor=HDMI-A-1,3840x2160@60,-3840x0,1

    # experimental:wide_color_gamut = yes        # Sets the colorspace to BT2020_RGB
    # experimental:xx_color_management_v4 = yes  # Required for HDR
    # experimental:hdr = yes                     # Forces HDR in desktop mode, will look weird without proper CM
  '';

  # HyprPaper wallpapers
  xdg.configFile."hypr/hyprpaper.conf".text = ''
    preload = ~/Pictures/Wallpapers/PinchFilter.png
    wallpaper = ,~/Pictures/Wallpapers/PinchFilter.png
  '';
}
