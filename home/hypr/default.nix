{
  # Hyprland config
  wayland.windowManager.hyprland = {
    enable = true;
    extraConfig = ''
      source = ./hyprland.common.conf
    '';
  };

  xdg.configFile."hypr/hyprland.common.conf".source = ./hyprland.common.conf;
  xdg.configFile."hypr/hyprland.host.conf".text = ""; # Just ensure file exists, it can be empty.
  xdg.configFile."hypr/hyprlock.conf".source = ./hyprlock.conf;
}
