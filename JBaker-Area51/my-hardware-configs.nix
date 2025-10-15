# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, lib, pkgs, ... }:

{
  networking.hostName = "JBaker-LT";
  nvidiaTweaks = true;
  josh.operator-mono.enable = true;

  nixpkgs.config.allowUnfree = true;
  nix.settings.auto-optimise-store = true;
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.initrd.luks.devices.cryptroot.device = "/dev/disk/by-uuid/0ecb2ae6-dfe2-444e-b06b-eee33d0aa8cb";
  boot.kernelPackages = pkgs.linuxPackages_latest;

  josh.username = "jbaker";
  users.users.${config.josh.username} = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" "adbusers" "dialout" "docker" "avahi" "vboxusers" "wireshark" ];
    description = "Josh Baker";
    packages = with pkgs; [
      (wrapOBS {
        plugins = with obs-studio-plugins; [
          input-overlay
        ];
      })
      claude-code
    ];
  };

  environment.variables.CVSROOT = ":ext:jbaker@eng1.eng.enseo.com/cvsroot";

  environment.systemPackages = with pkgs; [
    amazon-ecr-credential-helper
    amazon-ecs-cli
    awscli2
    cvs
    ffmpeg
    iptables
    joshua_bakers_qa_scripts.default
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
  # services.xserver.videoDrivers = [ "i915" "nvidia" ];

  # Add symlinks with consistent names for hyprland to identify which GPU is which
  services.udev.extraRules = ''
    KERNEL=="card*", KERNELS=="0000:01:00.0", SUBSYSTEM=="drm", SUBSYSTEMS=="pci", SYMLINK+="dri/nvidia-gpu"
    KERNEL=="card*", KERNELS=="0000:00:02.0", SUBSYSTEM=="drm", SUBSYSTEMS=="pci", SYMLINK+="dri/intel-gpu"
  '';

  virtualisation.docker.daemon.settings = {
    default-address-pools = [{
      base = "172.17.0.0/16";
      size = 24;
    }];
    mtu = 1300;
    dns = [ "192.168.50.25" "192.168.50.35" ];
    insecure-registries = [ "192.168.1.107:5000" ];
  };

  virtualisation.virtualbox.host.enable = true;

  # This is necessary with Virtualbox 7.1+ and Linux 6.12+ according to this conversation
  # https://github.com/NixOS/nixpkgs/issues/363887
  boot.kernelParams = [ "kvm.enable_virt_at_load=0" ];

  boot.supportedFilesystems = ["ntfs"];

  age.identityPaths = [ "/root/.ssh/id_ed25519" ];

  nmconnections = [ "5207" "Enseo_Auth" "Enseo-Guest" "Enseo_Management" "enseo-vpn" "Hotel_Guest" "Joshua" ];

  # 19467 is the external port I use when port forwarding from a NAT router,
  # but there's no NAT when using IPv6, so it's helpful to also listen on this port.
  services.openssh.ports = [ 22 19467 ];

  services.logind.settings.Login.HandleLidSwitch = "ignore";
  services.upower = {
    enable = true;
    ignoreLid = true;
  };
  # Disable GDM auto-suspend which broadcasts terminal messages and messes with services while I'm using the machine remotely!!!
  services.displayManager.gdm.autoSuspend = false;

  environment.binbash = pkgs.bash;

  # DHCP for 10.250.11.0/24 network
  # TODO: The ifnames need to be updated for this new device
  # services.kea.dhcp4 =
  #   let
  #     option = name: data: { inherit name data; };
  #   in
  #   {
  #     enable = true;
  #     settings = {
  #       authoritative = true;
  #       min-valid-lifetime = 10800;
  #       valid-lifetime = 21600;
  #       max-valid-lifetime = 86400;
  #       renew-timer = 3600;
  #       rebind-timer = 9000;
  #       interfaces-config = {
  #         interfaces = ["enp0s31f6"];
  #         # interfaces = ["enp0s31f6" "enp58s0u2"]; # Includes USB ethernet adapter
  #       };
  #       subnet4 = [
  #         {
  #           id = 1;
  #           pools = [{ pool = "10.250.11.10 - 10.250.11.254"; }];
  #           subnet = "10.250.11.0/24";
  #           option-data = [
  #             (option "domain-name" "stbs.local")
  #             (option "domain-name-servers" "192.168.50.35")
  #             (option "routers" "10.250.11.1")
  #           ];
  #         }
  #         # {
  #         #   id = 2;
  #         #   pools = [{ pool = "172.18.0.2 - 172.18.0.32"; }];
  #         #   subnet = "172.18.0.0/24";
  #         #   option-data = [
  #         #     (option "domain-name" "hotel.local")
  #         #     (option "domain-name-servers" "8.8.8.8")
  #         #     (option "routers" "172.18.0.1")
  #         #   ];
  #         # }
  #       ];
  #     };
  #   };

  systemd.tmpfiles.rules = [
    "L+ /run/gdm/.config/monitors.xml - - - - ${./monitors.xml}"
  ];

  services.conserver.enable = true;
  services.conserver.configFile = ../custom-configs/conserver/conserver.cf;

  # Needed for aqueduct
  services.avahi.enable = true;
  services.avahi.publish.enable = true;

  services.httpd = {
    enable = true;
    enablePHP = true;
    virtualHosts.http = {
      documentRoot = "/var/www/html";
      listen = [ {
        ip = "[::]";
        port = 8082;
      } ];
    };
    virtualHosts.https = {
      documentRoot = "/var/www/html";
      listen = [ {
        ip = "[::]";
        port = 8083;
        ssl = true;
      } ];
      sslServerCert = "/etc/ssl/certs/apache-selfsigned.crt";
      sslServerKey = "/etc/ssl/private/apache-selfsigned.key";
    };
    extraConfig = ''
      RewriteEngine on
      RewriteRule ^/proxy/(\d+) "http://localhost:$1" [P]

      <Directory /var/www/html>
        DirectoryIndex index.html index.php
      </Directory>
    '';
  };

  # This is necessary because newer versions of SSH do not support ssh-rsa by default anymore.
  # ssh-rsa is used by Enseo firmware.
  programs.ssh.pubkeyAcceptedKeyTypes = ["+ssh-rsa"];
  programs.ssh.hostKeyAlgorithms = ["+ssh-rsa"];

  # Causes IPv6 address to change periodically when enabled, which is bad because I have to configure
  # specific firewall rules at the router.
  networking.tempAddresses = "disabled";

  # Needed for multiverse
  networking.hosts = {
    "127.0.0.1" = [ "e3.custom.local" ];
  };

  # TODO: These ifnames need to be updated for this new device
  # networking.nftables.enable = true;
  # networking.nftables.tables = {
  #   nat.family = "inet";
  #   nat.content = ''
  #     chain POSTROUTING {
  #       # Masquerade packets forwarded from Hotel Guest to enseo-vpn
  #       iifname "enp58s0u2" oifname "enp0s31f6" counter masquerade random
  #     }
  #   '';

  #   filter.family = "inet";
  #   filter.content = ''
  #     chain FORWARD {
  #       # Accept incoming traffic from Hotel Guest
  #       iifname "enp58s0u2" oifname "enp0s31f6" counter accept

  #       # Rewrite traffic returning to Hotel Guest after masquerade
  #       iifname "enp0s31f6" oifname "enp58s0u2" ct state related,established counter accept
  #     }
  #   '';
  # };

  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  # system.copySystemConfiguration = true;

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
  system.stateVersion = "25.11"; # Did you read the comment?

}

