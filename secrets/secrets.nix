let
  Joshua-PC = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGYEtwhOUhooRNQ2KX/tQOyjQ+H3xRQcl87B2gGk3yp2";
  JBaker-LT = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFroq4+XRzI2mZtA4FQjV41vjx2eLln/C3n0NLMloTHH";
  joshuabaker-me = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPhWVW7ixMAKKsO9V/JLyt1FGkNtkAlLa1ttLpk6BmIL";
  Joshua-X1 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHoxcnKNlQTtFnf3jhrxEXGPZhvjwTlvZKgCjvNPOov3 root@Joshua-X1";

  publicKeys = [
    Joshua-PC
    JBaker-LT
    joshuabaker-me
    Joshua-X1
  ];
in
{
  "ddns-updater-config-Joshua-PC.age".publicKeys = publicKeys;
  "ddns-updater-config-JBaker-LT.age".publicKeys = publicKeys;
  "nmconnections/5207.nmconnection.age".publicKeys = publicKeys;
  "nmconnections/Enseo_Auth.nmconnection.age".publicKeys = publicKeys;
  "nmconnections/Enseo-Guest.nmconnection.age".publicKeys = publicKeys;
  "nmconnections/Enseo_Management.nmconnection.age".publicKeys = publicKeys;
  "nmconnections/enseo-vpn.nmconnection.age".publicKeys = publicKeys;
  "nmconnections/Hotel_Guest.nmconnection.age".publicKeys = publicKeys;
  "nmconnections/Joshua.nmconnection.age".publicKeys = publicKeys;
  "qbittorrent-env.age".publicKeys = publicKeys;
}
