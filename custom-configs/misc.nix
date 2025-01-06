{ pkgs, config, lib, ... }:

{
  options = {
    usePipeWire = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Whether to use PipeWire or Pulse";
    };

    useGrub = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Whether to use the GRUB or systemd bootloader";
    };

    bindMounts = lib.mkOption {
      type = lib.types.listOf (lib.types.attrsOf lib.types.str);
      default = [];
      description = "A list of bind-mounts to perform where each bind mount should be represented by an attribute set with keys \"src\" and \"at\", both strings.";
    };
  };

  config = {
    services.pipewire = lib.mkIf config.usePipeWire {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
    };

    # Enable sound (ALSA-based, includes pulseaudio)
    services.pulseaudio.enable = !config.usePipeWire;

    boot.loader = {
      grub = lib.mkIf config.useGrub {
        enable = true;
        device = "nodev";
        efiSupport = true;
        useOSProber = true;
        default = "saved";
      };
      systemd-boot.enable = !config.useGrub;
    };

    fileSystems = builtins.listToAttrs (builtins.map (
      { src, at }: {
        name = at;
        value = {
          options = ["bind"];
          device = src;
        };
      }
    ) config.bindMounts);
  };
}
