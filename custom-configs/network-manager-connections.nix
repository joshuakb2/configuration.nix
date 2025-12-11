{
  config,
  lib,
  ...
}:

{
  options.nmconnections = lib.mkOption {
    type = lib.types.listOf lib.types.str;
    default = [ ];
    description = "List of Network Manager connections to include on this system. For each value there should be a file called secrets/nmconnections/<value>.nmconnection.age.";
  };

  config = {
    age.secrets =
      let
        toKVP = name: {
          name = "nmconnection-${name}";
          value.file = "${../secrets/nmconnections}/${name}.nmconnection.age";
        };
      in
      builtins.listToAttrs (map toKVP config.nmconnections);

    environment.etc =
      let
        toKVP = name: {
          name = "/NetworkManager/system-connections/${name}.nmconnection";
          value.source = config.age.secrets."nmconnection-${name}".path;
        };
      in
      builtins.listToAttrs (map toKVP config.nmconnections);
  };
}
