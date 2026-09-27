{ lib, ... }:
{
  xdg.configFile."niri/config.kdl".source = ./config.kdl;
  xdg.configFile."niri/config.host.kdl".text = ""; # Just ensure file exists, it can be empty.
  home.activation.niri-custom-config = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    touch .config/niri/config.custom.kdl
  '';
}
