{ pkgs, config, lib, ... }:

let hyprlock-if-not-locked = pkgs.writeShellScriptBin "hyprlock-if-not-locked" ''
  if ${pkgs.procps}/bin/pgrep -x hyprlock &>/dev/null; then
    echo 'hyprlock already running, not running again'
  else
    ${pkgs.hyprlock}/bin/hyprlock
  fi
'';

in {
  options = {
    hyprland.displayToMirror = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "When assigned a value, extra connected displays will mirror the listed display instead of extending the desktop.";
    };
  };

  config = {
    # Hyprland config
    wayland.windowManager.hyprland = {
      enable = true;
      extraConfig = ''
        require("hyprland_common")
      '';
    };
    wayland.windowManager.hyprland.configType = "lua";

    xdg.configFile."hypr/hyprland_common.lua".source = ./hyprland_common.lua;
    xdg.configFile."hypr/hyprland_host.lua".text = ""; # Just ensure file exists, it can be empty.
    xdg.configFile."hypr/hyprlock.conf".source = ./hyprlock.conf;
    xdg.configFile."hypr/hyprland_extraMonitors.lua".text = let
      cfg = config.hyprland.displayToMirror;
      monitor = if builtins.isNull cfg then "<source monitor name>" else cfg;
      disableMirrored = if builtins.isNull cfg then "-- " else "";
      disableSideBySide = if builtins.isNull cfg then "" else "-- ";
    in ''
      -- For side-by-side screens
      ${disableSideBySide}hl.monitor({
      ${disableSideBySide}  output   = "",
      ${disableSideBySide}  mode     = "preferred",
      ${disableSideBySide}  position = "auto",
      ${disableSideBySide}  scale    = "auto",
      ${disableSideBySide}})

      -- For mirroring screens
      ${disableMirrored}hl.monitor({
      ${disableMirrored}  output   = "${monitor}",
      ${disableMirrored}  mode     = "preferred",
      ${disableMirrored}  position = "auto",
      ${disableMirrored}  scale    = "auto",
      ${disableMirrored}})
    '';

    home.packages = [
      hyprlock-if-not-locked
    ];

    home.activation.hyprland-wallpaperengine = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      touch .config/hypr/hyprland.wallpaperengine.conf
    '';
  };
}
