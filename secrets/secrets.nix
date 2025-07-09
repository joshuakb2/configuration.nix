let
  Joshua-PC = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGYEtwhOUhooRNQ2KX/tQOyjQ+H3xRQcl87B2gGk3yp2";
  JBaker-LT = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFroq4+XRzI2mZtA4FQjV41vjx2eLln/C3n0NLMloTHH";
  joshuabaker-me = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPhWVW7ixMAKKsO9V/JLyt1FGkNtkAlLa1ttLpk6BmIL";

  publicKeys = [
    Joshua-PC
    JBaker-LT
    joshuabaker-me
  ];
in
{
  "ddns-updater-config-Joshua-PC.age".publicKeys = publicKeys;
}
