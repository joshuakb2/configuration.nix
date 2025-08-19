# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, lib, pkgs, ... }:

{
  imports = [
    ./custom-configs
  ];

  nix.settings.auto-optimise-store = true;
  nix.settings.experimental-features = ["nix-command" "flakes"];
  nix.settings.download-buffer-size = 268435456;

  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelModules = ["v4l2loopback"];
  boot.extraModulePackages = [pkgs.linuxPackages.v4l2loopback];
  boot.initrd.systemd.emergencyAccess = true;

  # Pick only one of the below networking options.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  networking.networkmanager.enable = true;  # Easiest to use and most distros use this by default.
  networking.networkmanager.wifi.scanRandMacAddress = false;

  # Set your time zone.
  time.timeZone = "America/Denver";
  # time.timeZone = "America/Chicago";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";
  # console = {
  #   font = "Lat2-Terminus16";
  #   keyMap = "us";
  #   useXkbConfig = true; # use xkb.options in tty.
  # };

  services.resolved.enable = true;

  # Enable the X11 windowing system.
  services.xserver.enable = true;
  services.displayManager.gdm.enable = true;
  # services.xserver.displayManager.sddm.enable = true;
  # services.xserver.displayManager.sddm.wayland.enable = true;
  # services.xserver.displayManager.sddm.theme = "sugar-candy"; # See ./sddm-themes.nix
  useWayland = true;

  # Configure keymap in X11
  # services.xserver.xkb.layout = "us";
  # services.xserver.xkb.options = "eurosign:e,caps:escape";

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # See custom-configs/misc.nix
  usePipeWire = true;
  security.rtkit.enable = true;
  security.pam.services.swaylock.text = "auth include login";

  # Enable bluetooth
  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;
  hardware.bluetooth.settings.General.Experimental = "true"; # Get battery info

  # Enable touchpad support (enabled default in most desktopManager).
  services.libinput.enable = true;

  nixpkgs.config.allowUnfree = true;

  # Default shell
  users.defaultUserShell = pkgs.bash;

  users.users."${config.josh.username}".packages = with pkgs; [
      android-studio
      firefox
      gimp
      google-chrome
      graphite-cursors
      keepass
      mplayer
      mpv
      pavucontrol
      proton-authenticator
      qpwgraph
      signal-desktop
      slack
      speedtest-cli
      spotify
      slack
      teams-for-linux
      unzip
      vesktop # Discord for Wayland
      v4l-utils
      vlc
  ];

  # Declare plugdev group
  users.groups.plugdev = {};

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    alsa-utils
    android-udev-rules
    asciinema
    bash
    colordiff
    curl
    dig
    dunst
    edid-decode
    file
    filezilla
    gavin-bc
    gcc
    git
    gnumake
    grim
    grimblast
    hyprlauncher
    hyprlock
    hyprpaper
    inetutils
    jq
    kdePackages.dolphin
    killall
    kitty
    libnotify
    libreoffice
    make-it-so
    nautilus
    neofetch
    nixd
    nixfmt-rfc-style
    nodejs_22
    nodePackages.jshint
    nmap
    ntfs3g
    openvpn
    overskride
    pamixer
    pciutils
    python3
    python3Packages.pygments
    remmina
    (lib.meta.hiPrio rename) # Perl rename is way better than util-linux rename
    shellcheck
    slurp
    socat
    swayidle
    swaylock
    tmux
    tree
    unzip
    usbutils
    vulkan-hdr-layer
    waybar
    waypipe
    wget
    wl-clipboard
    wlr-randr
    wofi
    xclip
    xdg-user-dirs
    xxd
    yaru-theme
    zip
    zoom-us
  ];
  environment.variables = {
    EDITOR = "nvim";
    ELECTRON_OZONE_PLATFORM_HINT = "auto";
  };
  environment.sessionVariables.NIXOS_OZONE_WL = "1";
  environment.homeBinInPath = true;

  environment.etc = {
    # Configure pipewire for bluetooth
    "wireplumber/bluetooth.lua.d/51-bluez-config.lua".text = ''
      bluez_monitor.properties = {
        ["bluez5.enable-sbc-xq"] = true,
        ["bluez5.enable-msbc"] = true,
        ["bluez5.enable-hw-volume"] = true,
        ["bluez5.headset-roles"] = "[ hsp_hs hsp_ag hfp_hf hfp_ag ]"
      }
    '';

    # Needed for ExpressVPN via openvpn
    "openvpn/update-systemd-resolved".source = "${pkgs.openvpn-update-systemd-resolved}/bin/update-systemd-resolved";
  };

  services.pipewire.wireplumber.extraConfig.bluetoothEnhancements = {
    "monitor.bluez.properties" = {
        "bluez5.enable-sbc-xq" = true;
        "bluez5.enable-msbc" = true;
        "bluez5.enable-hw-volume" = true;
        "bluez5.headset-roles" = [ "hsp_hs" "hsp_ag" "hfp_hf" "hfp_ag" ];
    };
  };

  services.pipewire.extraConfig.pipewire."91-null-sinks" = {
    "context.objects" = [
      {
        # A default dummy driver. This handles nodes marked with the "node.always-driver"
        # properyty when no other driver is currently active. JACK clients need this.
        factory = "spa-node-factory";
        args = {
          "factory.name"     = "support.node.driver";
          "node.name"        = "Dummy-Driver";
          "priority.driver"  = 8000;
        };
      }
      {
        factory = "adapter";
        args = {
          "factory.name"     = "support.null-audio-sink";
          "node.name"        = "Microphone-Proxy";
          "node.description" = "Microphone";
          "media.class"      = "Audio/Source/Virtual";
          "audio.position"   = "MONO";
        };
      }
      {
        factory = "adapter";
        args = {
          "factory.name"     = "support.null-audio-sink";
          "node.name"        = "Main-Output-Proxy";
          "node.description" = "Main Output";
          "media.class"      = "Audio/Sink";
          "audio.position"   = "FL,FR";
        };
      }
    ];
  };

  # XDG sound theme support
  xdg.sounds.enable = true;
  xdg.mime.defaultApplications."inode/directory" = "org.gnome.Nautilus.desktop";

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  programs.mtr.enable = true;
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };
  programs.bash.shellAliases = {
    vim = "nvim";
    svim = "sudo -E nvim";
    grep = "grep --color=auto";
  };
  # Comes from the bash_completion file in the bash-completion package. Modified to include eou.
  programs.bash.shellInit = ''
    complete -f -o plusdirs -X '!*.@(zip|[aegjkswx]ar|exe|pk3|wsz|zargo|xpi|s[tx][cdiw]|sx[gm]|o[dt][tspgfc]|od[bm]|oxt|?(o)xps|epub|cbz|apk|aab|ipa|do[ct][xm]|p[op]t[mx]|xl[st][xm]|pyz|vsix|whl|[Ff][Cc][Ss]td|eou)' unzip zipinfo
  '';
  programs.neovim = {
    enable = true;
    defaultEditor = true;
  };
  programs.adb.enable = true;

  # Fix tap-to-click on GDM login screen
  programs.dconf.profiles.gdm.databases = [{
    settings."org/gnome/desktop/peripherals/mouse" = {
      natural-scroll = true;
    };
    settings."org/gnome/desktop/peripherals/touchpad" = {
      tap-to-click = true;
      click-method = "default";
    };
    settings."org/gnome/shell".enabled-extensions = with pkgs.gnomeExtensions; [
      multi-monitor-login.extensionUuid
    ];
  }];

  gdmExtensions = with pkgs.gnomeExtensions; [
    multi-monitor-login
  ];

  programs.wireshark.enable = true;
  programs.wireshark.package = pkgs.wireshark; # The default seems to be a bug, pkgs.wireshark-cli which does not exist

  fonts.packages = with pkgs; [
    font-awesome # Needed for waybar default icons
  ];

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;
  services.openssh.settings.X11Forwarding = true;

  services.tlp.enable = !config.services.desktopManager.gnome.enable && !config.services.desktopManager.plasma6.enable;
  services.tlp.settings = {
    CPU_SCALING_GOVERNOR_ON_AC = "performance";
    CPU_SCALING_GOVERNOR_ON_BAT = "powersave";
    CPU_ENERGY_PERF_POLICY_ON_AC = "performance";
    CPU_ENERGY_PERF_POLICY_ON_BAT = "power";
  };

  services.illum.enable = true;
  services.flatpak.enable = true;

  services.udev.extraRules = ''
    # Set settings for webcam
    SUBSYSTEM=="video4linux", ATTR{name}=="Dell Webcam WB3023", PROGRAM="${pkgs.v4l-utils}/bin/v4l2-ctl -d /dev/%k -c zoom_absolute=120"

    # Don't detect Keychron K10 keyboard as a controller!!!
    SUBSYSTEM=="input", ATTRS{idVendor}=="3434", ATTRS{idProduct}=="02a0", ENV{ID_INPUT_JOYSTICK}=""
  '';

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  networking.firewall.enable = false;

  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.

  # (not supported with flakes)
  # system.copySystemConfiguration = true;

  # Enable numlock during startup
  systemd.services.numLockOnTty = {
    wantedBy = ["multi-user.target"];
    serviceConfig = {
      ExecStart = pkgs.writeShellScript "numLockOnTty" ''
        for tty in /dev/tty{1..10}; do
          ${pkgs.kbd}/bin/setleds -D +num < "$tty";
        done
      '';
    };
  };

  # Support play/pause button on connected bluetooth headsets
  systemd.user.services.mpris-proxy = {
    description = "Mpris proxy";
    after = ["network.target" "sound.target"];
    wantedBy = ["default.target"];
    serviceConfig.ExecStart = "${pkgs.bluez}/bin/mpris-proxy";
  };

  # Fix Plex crashing on stop (https://github.com/NixOS/nixpkgs/issues/173338)
  systemd.services.plex.serviceConfig = let
    pidFile = "${config.services.plex.dataDir}/Plex Media Server/plexmediaserver.pid";
  in {
    KillSignal = lib.mkForce "SIGKILL";
    Restart = lib.mkForce "no";
    TimeoutStopSec = 10;
    ExecStop = ''
      ${pkgs.procps}/bin/pkill --signal 15 --pidfile "${pidFile}"

      # Wait until plex service has been shutdown
      # by checking if the PID file is gone
      while [ -e "${pidFile}" ]; do
        sleep 0.1
      done

      ${pkgs.coreutils}/bin/echo "Plex shutdown successful"
    '';
    PIDFile = lib.mkForce "";
  };

  virtualisation.docker.enable = true;

  specialisation.plasma.configuration.usePlasma = lib.mkForce true;
  specialisation.gnome.configuration.useGnome = lib.mkForce true;
}
