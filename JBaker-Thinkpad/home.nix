{ username, ... }:

{
  home.username = username;
  home.homeDirectory = "/home/${username}";
  programs.home-manager.enable = true;
  home.stateVersion = "24.11";

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
    -- hl.monitor({
    --   output   = "HDMI-A-1",
    --   mode     = "3440x1440@60",
    --   position = "3840x0",
    --   scale    = 1,
    -- })
    hl.monitor({
      output   = "DP-2",
      mode     = "preferred",
      position = "0x0",
      scale    = 1,
    })
    hl.monitor({
      output   = "DP-3",
      mode     = "preferred",
      position = "auto",
      scale    = 1,
    })
    hl.monitor({
      output   = "eDP-1",
      mode     = "preferred",
      position = "0x0",
      scale    = 1,
    })

    hl.config({ misc = { force_default_wallpaper = -1 } })
  '';

  # Host-specific bash init
  home.file.".bashrc_host".text = ''
    pushCORE() {
        (
            cd ~/projects/calica_dev/calica/web/apps/CORE
            ip=10.250.11.10
            stbscp $ip ../../CORE_engineSTB.html stb:/usr/local/share/web/
            stbscp $ip transpiled/riot-components+babel.js stb:/usr/local/share/web/apps/CORE/transpiled/
            stbscp $ip common/*.js stb:/usr/local/share/web/apps/CORE/common/
            stbscp $ip platformEnseoSTB/*.js  stb:/usr/local/share/web/apps/CORE/platformEnseoSTB/
            stbscp $ip js/*.js stb:/usr/local/share/web/apps/CORE/js/
            stbscp $ip css/*.css stb:/usr/local/share/web/apps/CORE/css/
            stbscp $ip arc/js/*.js stb:/usr/local/share/web/apps/CORE/arc/js/
        )
    }

    [[ -f /extra/projects/multiverse/.docker_helpers ]] && . /extra/projects/multiverse/.docker_helpers
  '';
}
