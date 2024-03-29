{ pkgs, config, lib, ... }:
{
  options = {
    usePipeWire = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Whether to use PipeWire or Pulse";
    };

    useWayland = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Whether to use Wayland or X.org";
    };

    programs.kpuinput.package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.kpuinput;
      description = "KPUInput package";
    };
    programs.kpuinput.enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Build kpuinput library for KeePass during activation";
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
    sound.enable = !config.usePipeWire;
    hardware.pulseaudio.enable = !config.usePipeWire;

    services.xserver.displayManager.gdm.wayland = config.useWayland;
    services.xserver.desktopManager.gnome.enable = !config.useWayland;
    programs = {
      hyprland.enable = config.useWayland;
    };

    environment.systemPackages = if config.programs.kpuinput.enable then [
      config.programs.kpuinput.package
    ] else [];

    users.groups.uinputg = lib.mkIf config.programs.kpuinput.enable {
      members = ["joshua"];
    };

    services.udev.packages = lib.mkIf config.programs.kpuinput.enable [
      (pkgs.stdenv.mkDerivation {
        name = "kpuinput-udev-rules";
        src = pkgs.writeTextFile rec {
          name = "kpuinput.rules";
          text = ''
            KERNEL=="uinput", GROUP="uinputg", MODE="0660", OPTIONS+="static_node=uinput"
          '';
          destination = "/lib/" + name;
        };
        dontBuild = true;
        installPhase = ''
          mkdir -p $out/lib/udev/rules.d
          cp lib/kpuinput.rules $out/lib/udev/rules.d/89-uinput-u.rules
        '';
      })
    ];

    system.activationScripts = {
      # kpuinput = if config.programs.kpuinput.enable then ''
      kpuinput = if false then ''
        echo Installing kpuinput
        rm -rf /tmp/kpuinput
        cp -r ${config.programs.kpuinput.package}/lib/dotnet/keepass /tmp/kpuinput
        cd /tmp/kpuinput
        ./build.sh
        mkdir -p /usr/lib
        mv KPUInputN.so /usr/lib/
        rm -rf /tmp/kpuinput
      '' else ''
        if [[ -f /usr/lib/KPUInputN.so ]]; then
          echo Uninstalling kpuinput
          rm -rf /usr/lib/KPUInputN.so
        fi
      '';
    };

    nixpkgs.overlays = lib.mkIf config.programs.kpuinput.enable [
      (final: prev: {
        keepass = import <nixpkgs/pkgs/applications/misc/keepass> {
          inherit (pkgs)
            lib fetchurl buildDotnetPackage substituteAll makeWrapper
            makeDesktopItem unzip icoutils gtk2 xorg xdotool xsel
            coreutils unixtools glib;

          plugins = [config.programs.kpuinput.package];
        };
      })
    ];
  };
}
