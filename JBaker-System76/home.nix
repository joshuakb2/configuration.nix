{ username, ... }:

{
  home.username = username;
  home.homeDirectory = "/home/${username}";
  programs.home-manager.enable = true;
  home.stateVersion = "26.11";

  imports = [ ../home ];

  # HyprPaper wallpapers
  xdg.configFile."hypr/hyprpaper.conf".text = ''
    preload = ~/Pictures/Wallpapers/colorful_fluid.png
    preload = ~/Pictures/Wallpapers/autumn_leaves.jpg
    preload = ~/Pictures/Wallpapers/space_has_no_limits.png

    wallpaper = eDP-1, ~/Pictures/Wallpapers/colorful_fluid.png
    wallpaper = DP-2, ~/Pictures/Wallpapers/autumn_leaves.jpg
    wallpaper = HDMI-A-1, ~/Pictures/Wallpapers/space_has_no_limits.png

    wallpaper = , ~/Pictures/Wallpapers/autumn_leaves.jpg
  '';

  # Host-specific Hyprland settings
  xdg.configFile."hypr/hyprland_host.lua".text = ''
    hl.config({
      debug = { disable_logs = false },
      cursor = { no_hardware_cursors = true },
      misc = { force_default_wallpaper = -1 },
    })

    hl.monitor({
      output   = "eDP-1",
      mode     = "1920x1080@144",
      position = "0x0",
      scale    = 1,
    })

    -- Use the NVIDIA card as the primary renderer. Otherwise, external displays lag like crazy.
    -- env = AQ_DRM_DEVICES,/dev/dri/nvidia-gpu:/dev/dri/intel-gpu
    hl.env("AQ_DRM_DEVICES", "/dev/dri/intel-gpu:/dev/dri/nvidia-gpu")
  '';

  xdg.configFile."niri/config.host.kdl".text = ''
    output "eDP-1" {
        mode "1920x1080@144.003"
        scale 1
        position x=0 y=0
    }
  '';

  # Host-specific bash init
  home.file.".bashrc_host".text = ''
    [[ -f $HOME/projects/multiverse/.docker_helpers ]] && . $HOME/projects/multiverse/.docker_helpers
  '';
}
