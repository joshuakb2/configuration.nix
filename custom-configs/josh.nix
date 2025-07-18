{ pkgs, config, lib, ... }:

{
  options.josh = {
    rook-row.enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Whether to include my rook-row script and completions";
    };

    operator-mono.enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Whether to include my operator mono fonts";
    };

    username = lib.mkOption {
      type = lib.types.str;
      description = "The username for the primary user account (usually joshua or jbaker)";
    };
  };

  config = let cfg = config.josh; in {
    users.users.${cfg.username} = {
      packages = lib.mkIf cfg.rook-row.enable [pkgs.rook-row];

      # Don't kill user processes on logoff
      linger = true;
    };

    security.sudo.extraRules = [{
      users = [cfg.username];
      commands = [{
        command = "ALL";
        options = ["NOPASSWD"];
      }];
    }];

    fonts.packages = lib.mkIf cfg.operator-mono.enable [pkgs.operator-mono-font];
  };
}
