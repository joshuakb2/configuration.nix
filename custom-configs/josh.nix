{
  pkgs,
  config,
  lib,
  ...
}:

{
  options.josh = {
    operator-mono.enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Whether to include my operator mono fonts";
    };

    username = lib.mkOption {
      type = lib.types.str;
      description = "The username for the primary user account (usually joshua or jbaker)";
    };

    pull-from-pc.enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Whether to use PC as a substituter";
    };

    pull-from-work.enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Whether to use work laptop as a substituter";
    };

    nixServe.enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Whether to use nix-serve to share built derivations with other machines";
    };
  };

  config =
    let
      cfg = config.josh;
    in
    {
      users.users.${cfg.username} = {
        # Don't kill user processes on logoff
        linger = true;
      };

      security.sudo.extraRules = [
        {
          users = [ cfg.username ];
          commands = [
            {
              command = "ALL";
              options = [ "NOPASSWD" ];
            }
          ];
        }
      ];

      fonts.packages = lib.mkIf cfg.operator-mono.enable [ pkgs.operator-mono-font ];

      nix.settings =
        let
          subs = lib.mkMerge [
            (lib.mkIf cfg.pull-from-pc.enable [ "http://pc.joshuabaker.me:6321/" ])
            (lib.mkIf cfg.pull-from-work.enable [ "http://work.joshuabaker.me:6321/" ])
          ];
        in
        {
          substituters = subs;
          trusted-substituters = subs;
          trusted-public-keys = [ (builtins.readFile ../secrets/nix-serve.pub) ];
        };

      age.secrets.nix-serve-private-key = lib.mkIf cfg.nixServe.enable {
        file = ../secrets/nix-serve.key.age;
      };

      services.nix-serve = lib.mkIf cfg.nixServe.enable {
        enable = true;
        bindAddress = "127.0.0.1"; # only supports IPv4 addresses. We have to use nginx to reverse proxy for IPv6 support :(
        port = 6322;
        secretKeyFile = config.age.secrets.nix-serve-private-key.path;
      };

      services.nginx = lib.mkIf cfg.nixServe.enable {
        enable = true;
        recommendedGzipSettings = true;
        virtualHosts.nix-serve = {
          listen = [ { addr = "[::]"; port = 6321; } ];
          locations."/".proxyPass = "http://127.0.0.1:6322";
        };
      };
    };
}
