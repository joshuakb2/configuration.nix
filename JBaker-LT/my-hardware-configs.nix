{ pkgs, config, ... }:
{
  imports = [./conserver.nix];

  networking.hostName = "JBaker-LT";
  nvidiaTweaks = true;
  useGrub = true;
  josh.operator-mono.enable = true;

  services.throttled.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  josh.username = "jbaker";
  users.users.${config.josh.username} = {
    isNormalUser = true;
    extraGroups = ["wheel" "networkmanager" "adbusers" "dialout" "docker" "avahi" "vboxusers" "wireshark"];
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
    amazon-ecs-cli
    awscli2
    cvs
    ffmpeg
    iptables
    python311Packages.avahi
    tcpdump
  ];

  virtualisation.docker.enable = true;
  virtualisation.docker.daemon.settings = {
    data-root = "/extra/docker";
    default-address-pools = [{
      base = "172.17.0.0/16";
      size = 24;
    }];
    mtu = 1300;
    dns = ["192.168.50.25" "192.168.50.35"];
  };

  virtualisation.virtualbox.host.enable = true;
  virtualisation.virtualbox.guest.enable = true;

  boot.supportedFilesystems = ["ntfs"];

  services.logind.lidSwitch = "ignore";
  services.upower = {
    enable = true;
    ignoreLid = true;
  };
  # Disable GDM auto-suspend which broadcasts terminal messages and messes with services while I'm using the machine remotely!!!
  services.xserver.displayManager.gdm.autoSuspend = false;

  environment.binbash = pkgs.bash;

  # DHCP for 10.250.11.0/24 network
  services.kea.dhcp4 =
    let
      option = name: data: { inherit name data; };
    in
    {
      enable = true;
      settings = {
        loggers = [
          {
            name = "kea-dhcp4";
            severity = "DEBUG";
            debuglevel = 99;
            output_options = [
              {
                output = "/var/log/kea.log";
                flush = true;
              }
            ];
          }
        ];
        authoritative = true;
        min-valid-lifetime = 10800;
        valid-lifetime = 21600;
        max-valid-lifetime = 86400;
        renew-timer = 3600;
        rebind-timer = 9000;
        interfaces-config = {
          # interfaces = ["enp0s31f6"];
          interfaces = ["enp0s31f6" "enp58s0u1"]; # Includes USB ethernet adapter
        };
        subnet4 = [
          {
            id = 1;
            pools = [{ pool = "10.250.11.10 - 10.250.11.254"; }];
            subnet = "10.250.11.0/24";
            option-data = [
              (option "domain-name" "stbs.local")
              (option "domain-name-servers" "192.168.50.35")
              (option "routers" "10.250.11.1")
            ];
          }
          {
            id = 2;
            pools = [{ pool = "172.18.0.2 - 172.18.0.32"; }];
            subnet = "172.18.0.0/24";
            option-data = [
              (option "domain-name" "hotel.local")
              (option "domain-name-servers" "8.8.8.8")
              (option "routers" "172.18.0.1")
            ];
          }
        ];
        lease-database = {
          type = "memfile";
          persist = true;
          name = "/var/lib/kea/kea-leases4.csv";
        };
      };
    };

  systemd.tmpfiles.rules = [
    "L+ /run/gdm/.config/monitors.xml - - - - ${./monitors.xml}"
  ];

  services.conserver.enable = true;
  services.conserver.configFile = ./conserver.cf;

  # Needed for aqueduct
  services.avahi.enable = true;
  services.avahi.publish.enable = true;

  services.httpd = {
    enable = true;
    enablePHP = true;
    virtualHosts.http = {
      documentRoot = "/var/www/html";
      listen = [{ port = 8082; }];
    };
    virtualHosts.https = {
      documentRoot = "/var/www/html";
      listen = [{ port = 8083; ssl = true; }];
      sslServerCert = "/etc/ssl/certs/apache-selfsigned.crt";
      sslServerKey = "/etc/ssl/private/apache-selfsigned.key";
    };
    extraConfig = ''
      RewriteEngine on
      RewriteRule ^/proxy/(\d+) "http://localhost:$1" [P]

      <Directory /var/www/html>
        Options FollowSymlinks Indexes
        AllowOverride All
      </Directory>
    '';
  };

  # This is necessary because newer versions of SSH do not support ssh-rsa by default anymore.
  # ssh-rsa is used by Enseo firmware.
  programs.ssh.pubkeyAcceptedKeyTypes = ["+ssh-rsa"];
  programs.ssh.hostKeyAlgorithms = ["+ssh-rsa"];

  networking.nftables.enable = true;
  networking.nftables.tables = {
    nat.family = "inet";
    nat.content = ''
      chain POSTROUTING {
        # Masquerade packets forwarded from Hotel Guest to enseo-vpn
        iifname "enp58s0u1" oifname "enp0s31f6" counter masquerade random
      }
    '';

    filter.family = "inet";
    filter.content = ''
      chain FORWARD {
        # Accept incoming traffic from Hotel Guest
        iifname "enp58s0u1" oifname "enp0s31f6" counter accept

        # Rewrite traffic returning to Hotel Guest after masquerade
        iifname "enp0s31f6" oifname "enp58s0u1" ct state related,established counter accept
      }
    '';
  };
}
