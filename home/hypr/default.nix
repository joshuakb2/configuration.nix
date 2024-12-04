{ pkgs, config, lib, ... }:

let hyprlock-if-not-locked = pkgs.writeShellScriptBin "hyprlock-if-not-locked" ''
  if ${pkgs.procps}/bin/pgrep hyprlock &>/dev/null; then
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
        source = ./hyprland.common.conf
      '';
    };

    xdg.configFile."hypr/hyprland.common.conf".source = ./hyprland.common.conf;
    xdg.configFile."hypr/hyprland.host.conf".text = ""; # Just ensure file exists, it can be empty.
    xdg.configFile."hypr/hyprlock.conf".source = ./hyprlock.conf;
    xdg.configFile."hypr/hyprland.extraMonitors.conf".text = let
      cfg = config.hyprland.displayToMirror;
      monitor = if builtins.isNull cfg then "<source monitor name>" else cfg;
      disableMirrored = if builtins.isNull cfg then "# " else "";
      disableSideBySide = if builtins.isNull cfg then "" else "# ";
    in ''
      # For side-by-side screens
      ${disableSideBySide}monitor=,preferred,auto,auto

      # For mirroring screens
      ${disableMirrored}monitor=,preferred,auto,1,mirror,${monitor}
    '';

    home.packages = [
      hyprlock-if-not-locked
    ];
  };
}
