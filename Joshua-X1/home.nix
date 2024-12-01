{ pkgs, username, hyprgrass, ... }:

{
  home.username = username;
  home.homeDirectory = "/home/${username}";
  programs.home-manager.enable = true;
  home.stateVersion = "24.11";

  imports = [../home];

  wayland.windowManager.hyprland.plugins = [
    hyprgrass.packages.${pkgs.system}.default
  ];
}
