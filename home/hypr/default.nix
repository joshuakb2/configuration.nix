{
  # Hyprland config
  wayland.windowManager.hyprland = {
    enable = true;
    extraConfig = ''
      source = ./hyprland.common.conf
    '';
  };

  xdg.configFile."hypr/hyprland.common.conf".source = ./hyprland.common.conf;
  xdg.configFile."hypr/hyprlock.conf".source = ./hyprlock.conf;
}
