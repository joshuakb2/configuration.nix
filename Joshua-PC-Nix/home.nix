{ username, ... }:

{
  home.username = username;
  home.homeDirectory = "/home/${username}";
  programs.home-manager.enable = true;
  home.stateVersion = "24.11";

  imports = [../home];
}
