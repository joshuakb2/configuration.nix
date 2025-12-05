{ username, ... }:

{
  home.username = username;
  home.homeDirectory = "/home/${username}";
  programs.home-manager.enable = true;
  home.stateVersion = "24.11";

  imports = [../home];

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
  xdg.configFile."hypr/hyprland.host.conf".text = ''
    #monitor=HDMI-A-1,3440x1440@60,3840x0,1
    monitor=DP-2,preferred,0x0,1
    monitor=DP-3,preferred,auto,1
    monitor=eDP-1,preferred,0x0,1

    misc:force_default_wallpaper = -1
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
