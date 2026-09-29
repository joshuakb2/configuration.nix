{ username, ... }:

{
  home.username = username;
  home.homeDirectory = "/home/${username}";
  programs.home-manager.enable = true;
  home.stateVersion = "24.11";

  imports = [../home];

  # Host-specific Hyprland settings
  xdg.configFile."hypr/hyprland_host.lua".text = ''
    hl.monitor({
      output   = "DP-3",
      mode     = "3440x1440@144",
      position = "0x0",
      scale    = 1,
      vrr      = 3,
    })
    hl.monitor({
      output   = "DP-2",
      mode     = "3840x2160@120",
      position = "-2560x0",
      scale    = 1.5,
    })

    hl.on("hyprland.start", function()
      hl.exec_cmd("start-everywhere-to-my-ears-loopback")
    end)

    -- OBS hotkeys
    hl.bind("ALT + SHIFT + S", hl.dsp.pass({ window = "class:com.obsproject.Studio" }))

    hl.config({
      xwayland = { force_zero_scaling = true },
    })

    hl.window_rule({
      float = true,
      match = { class = "[Ww]aydroid.*" },
    })
  '';

  # HyprPaper wallpapers
  xdg.configFile."hypr/hyprpaper.conf".text = ''
    preload = ~/Pictures/Wallpapers/PinchFilter.png
    wallpaper = ,~/Pictures/Wallpapers/PinchFilter.png
  '';

  xdg.configFile."niri/config.host.kdl".text = ''
    output "DP-3" {
        mode "3440x1440@143.975"
        scale 1
        position x=0 y=0
    }
    output "DP-2" {
        mode "3840x2160@120.000"
        scale 1.5
        position x=-2560 y=0
    }

    spawn-at-startup "start-everywhere-to-my-ears-loopback"

    layout {
      preset-column-widths {
          proportion 0.25
          proportion 0.5
          proportion 0.75
        }
      }
  '';
}
