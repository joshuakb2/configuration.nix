let
  system1 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGYEtwhOUhooRNQ2KX/tQOyjQ+H3xRQcl87B2gGk3yp2";

in
{
  "ddns-updater-config-Joshua-PC.age".publicKeys = [ system1 ];
}
