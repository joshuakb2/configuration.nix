{ hyprgrass, ... }: { config, pkgs, ... }:

{
  home.username = "joshua";
  home.homeDirectory = "/home/joshua";
  programs.home-manager.enable = true;
  home.stateVersion = "24.11";

  wayland.windowManager.hyprland = {
    enable = true;
    package = pkgs.hyprland;
    plugins = [
      hyprgrass.packages.${pkgs.system}.default
    ];
    extraConfig = ''
      source = ./hyprland.local.conf
    '';
  };
}
