let
  Joshua-PC = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGYEtwhOUhooRNQ2KX/tQOyjQ+H3xRQcl87B2gGk3yp2";
  JBaker-Area51 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBPKtl1XO7cA6xD1Mo7MhQWnryhKI2lYAAfm1OhY4W9I";
  JBaker-Thinkpad = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFroq4+XRzI2mZtA4FQjV41vjx2eLln/C3n0NLMloTHH";
  joshuabaker-me = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPhWVW7ixMAKKsO9V/JLyt1FGkNtkAlLa1ttLpk6BmIL";
  Joshua-X1 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHoxcnKNlQTtFnf3jhrxEXGPZhvjwTlvZKgCjvNPOov3 root@Joshua-X1";

  publicKeys = [
    Joshua-PC
    JBaker-Area51
    JBaker-Thinkpad
    joshuabaker-me
    Joshua-X1
  ];

  secretFiles = [
    "ddns-updater-config-JBaker-Area51.age"
    "ddns-updater-config-Joshua-PC.age"
    "ddns-updater-config-JBaker-Thinkpad.age"
    "nix-serve.key.age"
    "nmconnections/5207.nmconnection.age"
    "nmconnections/Enseo_Auth.nmconnection.age"
    "nmconnections/Enseo-Guest.nmconnection.age"
    "nmconnections/Enseo_Management.nmconnection.age"
    "nmconnections/enseo-vpn.nmconnection.age"
    "nmconnections/Hotel_Guest.nmconnection.age"
    "nmconnections/Joshua.nmconnection.age"
    "qbittorrent-env.age"
  ];

  toSetting = secretFile: {
    name = secretFile;
    value = { inherit publicKeys; };
  };
in
builtins.listToAttrs (map toSetting secretFiles)
