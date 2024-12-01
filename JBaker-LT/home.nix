{ username, ... }:

{
  home.username = username;
  home.homeDirectory = "/home/${username}";
  programs.home-manager.enable = true;
  home.stateVersion = "24.11";

  imports = [../home];

  programs.bash.bashrcExtra = ''
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
  '';
}
