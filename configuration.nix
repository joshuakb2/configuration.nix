# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, lib, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      # ./my-overlays.nix
      # ./sddm-themes.nix
      ./neovim-nightly.nix
    ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Needed for suspend to work correctly, I'm told by Hyprland
  boot.kernelParams = [
    "nvidia.NVreg_PreserveVideoMemoryAllocations=1"
    "nvidia_drm.fbdev=1" # Without this, TTY framebuffers don't work (Ctrl-Alt-Fn)
  ];

  networking.hostName = "Joshua-PC-Nix"; # Define your hostname.
  # Pick only one of the below networking options.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  networking.networkmanager.enable = true;  # Easiest to use and most distros use this by default.

  hardware.opengl = {
    enable = true;
    extraPackages = [pkgs.libvdpau-va-gl];
    driSupport = true;
    driSupport32Bit = true;
  };

  services.xserver.videoDrivers = ["nvidia"];

  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement.enable = false;
    powerManagement.finegrained = false;
    open = false;
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.stable;
  };

  # Set your time zone.
  time.timeZone = "America/Denver";

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";
  # console = {
  #   font = "Lat2-Terminus16";
  #   keyMap = "us";
  #   useXkbConfig = true; # use xkb.options in tty.
  # };

  # Enable the X11 windowing system.
  services.xserver.enable = true;
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.displayManager.gdm.wayland = true;
  services.xserver.displayManager.gdm.autoSuspend = true;
  # services.xserver.displayManager.sddm.enable = true;
  # services.xserver.displayManager.sddm.wayland.enable = true;
  # services.xserver.displayManager.sddm.theme = "sugar-candy"; # See ./sddm-themes.nix
  programs.hyprland.enable = true;
  programs.hyprland.package = pkgs.hyprland.overrideAttrs {
    version = "0.35.0";
  };
  programs.hyprland.enableNvidiaPatches = true;

  services.httpd.enable = true;

  # Configure keymap in X11
  # services.xserver.xkb.layout = "us";
  # services.xserver.xkb.options = "eurosign:e,caps:escape";

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound.
  sound.enable = true;
  hardware.pulseaudio.enable = true;

  # Enable bluetooth
  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  nixpkgs.config.allowUnfree = true;

  # Default shell
  users.defaultUserShell = pkgs.bash;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.joshua = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" ]; # Enable ‘sudo’ for the user.
    description = "Joshua Baker";
    packages = with pkgs; [
      firefox
      chromium
      steam
      keepass
      discord
      nodejs_18
      pavucontrol
      signal-desktop
    ];
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    bash
    curl
    dig
    dolphin
    file
    git
    grim
    killall
    kitty
    neofetch
    ntfs3g
    slurp
    swayidle
    tmux
    tree
    wget
    wl-clipboard
    wofi
    xdg-user-dirs
    xxd
  ];
  environment.variables = {
    EDITOR = "nvim";
    ELECTRON_OZONE_PLATFORM_HINT = "auto";
    VDPAU_DRIVER = "va_gl";
    LIBVA_DRIVER_NAME = "nvidia";
  };
  environment.sessionVariables.NIXOS_OZONE_WS = "1";

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  programs.mtr.enable = true;
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };
  programs.bash.shellAliases = {
    vim = "nvim";
  };
  programs.neovim = {
    enable = true;
    defaultEditor = true;
  };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  networking.firewall.enable = false;

  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  system.copySystemConfiguration = true;

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

