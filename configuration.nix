# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, lib, pkgs, ... }:

{
  imports = [./my-custom-configs.nix];

  nix.settings.auto-optimise-store = true;
  nix.settings.experimental-features = ["nix-command" "flakes"];

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
  services.xserver.displayManager.gdm.enable = true;
  # services.xserver.displayManager.gdm.autoSuspend = true;
  # services.xserver.displayManager.sddm.enable = true;
  # services.xserver.displayManager.sddm.wayland.enable = true;
  # services.xserver.displayManager.sddm.theme = "sugar-candy"; # See ./sddm-themes.nix
  useWayland = true;
  programs.hyprland.package = pkgs.hyprland.overrideAttrs {
    version = "0.35.0";
  };
  programs.steam.enable = true;

  services.httpd.enable = true;
  services.httpd.virtualHosts.localhost = {
    documentRoot = "/var/www/html";
    listen = [{ port = 80; }];
    extraConfig = ''
      <Directory /var/www/html>
        Options FollowSymlinks Indexes
        AllowOverride All
      </Directory>
    '';
  };

  # Configure keymap in X11
  # services.xserver.xkb.layout = "us";
  # services.xserver.xkb.options = "eurosign:e,caps:escape";

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # See my-custom-configs.nix
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

  users.users."${config.myUserName}".packages = with pkgs; [
      android-studio
      arduino
      discord
      firefox
      gimp
      google-chrome
      graphite-cursors
      keepass
      mplayer
      nodejs_18
      obs-studio
      pavucontrol
      qbittorrent
      qpwgraph
      rook-row
      signal-desktop
      spotify
      steam
      teams-for-linux
      unzip
      vlc
  ];

  # Declare plugdev group
  users.groups.plugdev = {};

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    android-udev-rules
    bash
    betterdiscordctl
    curl
    dig
    dolphin
    dunst
    ffmpeg
    file
    gamescope
    git
    grim
    grimblast
    hyprpaper
    hyprpicker
    killall
    kitty
    libnotify
    neofetch
    ntfs3g
    openvpn
    pamixer
    slurp
    swayidle
    swaylock
    tmux
    tree
    waybar
    wget
    wl-clipboard
    wlr-randr
    wofi
    xdg-user-dirs
    xxd
    yaru-theme
  ];
  environment.variables = {
    EDITOR = "nvim";
    ELECTRON_OZONE_PLATFORM_HINT = "auto";
  };
  environment.sessionVariables.NIXOS_OZONE_WS = "1";
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

  # Use this in nixos-unstable or nixos-24.05
  services.pipewire.wireplumber.configPackages = [
    # Configure pipewire for bluetooth
    (pkgs.writeTextDir "share/wireplumber/wireplumber/wireplumber.conf.d/51-bluez.conf" ''
      monitor.bluez.properties = {
        bluez5.enable-sbc-xq = true
        bluez5.enable-msbc = true
        bluez5.enable-hw-volume = true
        bluez5.headset-roles = [ hsp_hs hsp_ag hfp_hf hfp_ag ]
      }
    '')
  ];

  # XDG sound theme support
  xdg.sounds.enable = true;

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
  };
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
  }];

  fonts.packages = with pkgs; [
    operator-mono-font
    font-awesome # Needed for waybar default icons
  ];

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;
  services.openssh.settings.X11Forwarding = true;

  services.tlp.enable = !config.services.xserver.desktopManager.gnome.enable;
  services.illum.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  networking.firewall.enable = false;

  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
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

  # Turn off display when idle
  # systemd.user.services.swayidle = {
  #   wantedBy = ["default.target"];
  #   path = with pkgs; [swayidle hyprland];
  #   serviceConfig = {
  #     ExecStart = pkgs.writeShellScript "runSwayidle" ''
  #       swayidle -w timeout 30 "echo Timeout && hyprctl dispatch dpms off" resume "echo Resume && hyprctl dispatch dpms on"
  #     '';
  #     Restart = "on-failure";
  #     RestartSec = "5";
  #   };
  # };

  # This option defines the first version of NixOS you have installed on this particular machine,
  # and is used to maintain compatibility with application data (e.g. databases) created on older NixOS versions.
  #
  # Most users should NEVER change this value after the initial install, for any reason,
  # even if you've upgraded your system to a new NixOS release.
  #
  # This value does NOT affect the Nixpkgs version your packages and OS are pulled from,
  # so changing it will NOT upgrade your system.
  #
  # This value being lower than the current NixOS release does NOT mean your system is
  # out of date, out of support, or vulnerable.
  #
  # Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
  # and migrated your data accordingly.
  #
  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "23.11"; # Did you read the comment?
}

