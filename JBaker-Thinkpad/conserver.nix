{ pkgs, config, lib, ... }:
{
  options = {
    services.conserver = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Whether to enable the conserver daemon";
      };

      package = lib.mkOption {
        type = lib.types.package;
        default = pkgs.conserver;
        description = "Which conserver package to use";
      };

      configFile = lib.mkOption {
        type = lib.types.nullOr lib.types.path;
        default = null;
        description = "Path to the conserver.cf file";
      };
    };
  };

  config =
  let cfg = config.services.conserver;
  in {
    environment.etc.services.source = lib.mkIf cfg.enable (lib.mkForce (pkgs.runCommand "services-with-conserver" {} ''
      cp ${pkgs.iana-etc}/etc/services $out
      chmod +w $out
      echo conserver 782/tcp >> $out
      echo conserver 782/udp >> $out
    ''));

    systemd.services.conserver = lib.mkIf cfg.enable {
      description = "The conserver server daemon";
      wantedBy = ["multi-user.target"];
      after = ["network.target"];
      serviceConfig = {
        ExecStartPre = "${pkgs.coreutils}/bin/mkdir -p /var/log/conserver";
        ExecStart = "${cfg.package}/bin/conserver -C ${cfg.configFile}";
        Restart = "always";
      };
    };

    environment.systemPackages = lib.mkIf cfg.enable [cfg.package];
  };
}
