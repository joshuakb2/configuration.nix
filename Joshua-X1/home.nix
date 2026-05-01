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
  xdg.configFile."hypr/hyprland_host.lua".text = let
    primaryMonitor =
      transform:
        ''hl.monitor({ output = "eDP-1", mode = "1920x1080@60", position = "0x0", scale = 1, transform = ${transform} })'';
  in ''
    ${primaryMonitor "0"}
    -- hl.monitor({ output = "HDMI-A-1", mode = "3440x1440@175", position = "0x0", scale = 1 })

    hl.bind(mainMod .. " + F", hl.dsp.exec_cmd("hyprctl eval \"${primaryMonitor "0"}\""))
    hl.bind(mainMod .. " + ALT + F", hl.dsp.exec_cmd("hyprctl eval \"${primaryMonitor "2"}\""))
  '';

  hyprland.displayToMirror = "eDP-1";

  # HyprPaper wallpapers
  xdg.configFile."hypr/hyprpaper.conf".text = ''
    preload = ~/Pictures/Wallpapers/PinchFilter.png
    wallpaper = ,~/Pictures/Wallpapers/PinchFilter.png
  '';
}
