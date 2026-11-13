# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{
  config,
  lib,
  pkgs,
  ...
}:

{
  networking.hostName = "JBaker-System76";
  nvidiaTweaks = true;
  nvidiaInInitrd = false;
  nvidiaPascal = false;
  josh.operator-mono.enable = true;

  josh.nixServe.enable = true;
  josh.pull-from-pc.enable = true;

  nixpkgs.config.allowUnfree = true;
  nix.settings.auto-optimise-store = true;
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.initrd.luks.devices.cryptroot.device =
    "/dev/disk/by-uuid/488571b0-64c3-4bc1-a70c-80251342aa41";
  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.initrd.kernelModules = [ "i915" ];

  josh.username = "jbaker";
  users.users.${config.josh.username} = {
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "networkmanager"
      "adbusers"
      "dialout"
      "docker"
      "avahi"
      "vboxusers"
      "wireshark"
    ];
    description = "Josh Baker";
    packages = with pkgs; [
      (wrapOBS {
        plugins = with obs-studio-plugins; [
          input-overlay
        ];
      })
    ];
  };

  environment.variables.CVSROOT = ":ext:jbaker@eng1.eng.enseo.com/cvsroot";

  environment.systemPackages = with pkgs; [
    amazon-ecr-credential-helper
    awscli2
    cvs
    enseo-vpn
    ffmpeg
    iptables
    # joshua_bakers_qa_scripts.default
    python311Packages.avahi
    tcpdump
  ];

  hardware.nvidia = {
    powerManagement.enable = lib.mkForce true;
    open = lib.mkForce true;
    prime.intelBusId = "PCI:0:2:0";
    prime.nvidiaBusId = "PCI:1:0:0";
    prime.sync.enable = true;
  };

  # Despite the fact that we have an intel GPU in this machine,
  # we don't want the i915 driver listed here because that can cause
  # applications to try to use the intel GPU instead of the nvidia GPU.
  # That causes problems because hyprland is set to use the nvidia GPU
  # as the primary renderer, because when the intel GPU is the primary
  # renderer, external displays are super laggy.
  # services.xserver.videoDrivers = lib.mkForce [ "i915" "nvidia" ];

  # Add symlinks with consistent names for hyprland to identify which GPU is which
  services.udev.extraRules = ''
    KERNEL=="card*", KERNELS=="0000:01:00.0", SUBSYSTEM=="drm", SUBSYSTEMS=="pci", SYMLINK+="dri/nvidia-gpu"
    KERNEL=="card*", KERNELS=="0000:00:02.0", SUBSYSTEM=="drm", SUBSYSTEMS=="pci", SYMLINK+="dri/intel-gpu"
  '';

  virtualisation.docker.daemon.settings = {
    default-address-pools = [
      {
        base = "172.17.0.0/16";
        size = 24;
      }
    ];
    mtu = 1300;
    insecure-registries = [
      "[::1]:5000"
      "127.0.0.1:5000"
      "alien-repo:5000"
    ];
  };

  # Temporarily disabled due to build failure: https://github.com/NixOS/nixpkgs/issues/491434
  # virtualisation.virtualbox.host.enable = true;

  boot.supportedFilesystems = [ "ntfs" ];

  nmconnections = [
    "FortressOfSolitude"
    "Enseo_Auth"
    "Enseo-Guest"
    "Enseo_Management"
    "enseo-vpn"
    "Hotel_Guest"
    "Joshua"
  ];

  services.openssh.settings.PasswordAuthentication = false;

  services.logind.settings.Login.HandleLidSwitch = "ignore";
  services.upower = {
    enable = true;
    ignoreLid = true;
  };
  # Disable GDM auto-suspend which broadcasts terminal messages and messes with services while I'm using the machine remotely!!!
  services.displayManager.gdm.autoSuspend = false;

  environment.binbash = pkgs.bash;

  # Needed for aqueduct
  services.avahi.enable = true;
  services.avahi.publish.enable = true;

  services.fwupd.enable = true;

  # This is necessary because newer versions of SSH do not support ssh-rsa by default anymore.
  # ssh-rsa is used by Enseo firmware.
  programs.ssh.pubkeyAcceptedKeyTypes = [ "+ssh-rsa" ];
  programs.ssh.hostKeyAlgorithms = [ "+ssh-rsa" ];

  # Causes IPv6 address to change periodically when enabled, which is bad because I have to configure
  # specific firewall rules at the router.
  networking.tempAddresses = "disabled";

  # Needed for multiverse
  networking.hosts = {
    "127.0.0.1" = [
      "e3.custom.local"
      "alien-repo"
    ];
  };

  # This option defines the first version of NixOS you have installed on this particular machine,
  # and is used to maintain compatibility with application data (e.g. databases) created on older NixOS versions.
  #
  # Most users should NEVER change this value after the initial install, for any reason,
  # even if you've upgraded your system to a new NixOS release.
  #
  # This value does NOT affect the Nixpkgs version your packages and OS are pulled from,
  # so changing it will NOT upgrade your system - see https://nixos.org/manual/nixos/stable/#sec-upgrading for how
  # to actually do that.
  #
  # This value being lower than the current NixOS release does NOT mean your system is
  # out of date, out of support, or vulnerable.
  #
  # Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
  # and migrated your data accordingly.
  #
  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "26.11"; # Did you read the comment?
}
