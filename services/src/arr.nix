# Auto-generated using compose2nix v0.2.0-pre.
{ pkgs, lib, ... }:

{
  # Runtime
  virtualisation.podman = {
    enable = true;
    autoPrune.enable = true;
    dockerCompat = true;
    defaultNetwork.settings = {
      dns_enabled = true;
    };
  };
  virtualisation.oci-containers.backend = "podman";

  # Containers
  virtualisation.oci-containers.containers."prowlarr" = {
    # Check linuxserver/prowlarr for the latest stable tag
    image = "linuxserver/prowlarr:1.20.1"; # Example, use current stable tag
    environment = {
      PGID = "1000";
      PUID = "1000";
      TZ = "America/Bogota";
    };
    volumes = [
      # Config Path - Remains the same
      "/home/danielgm/Documents/Services/nixarr/media/prowlarr:/config:rw"
      # Optional watch folder - path depends on downloads setup
      # "/home/danielgm/Documents/Services/nixarr/media/downloads/watch:/downloads:rw"
    ];
    ports = [ "9696:9696/tcp" ];
    log-driver = "journald";
    extraOptions = [
      "--network-alias=prowlarr"
      "--network=nixarr_default"
    ];
  };
  systemd.services."podman-prowlarr" = {
    serviceConfig = { Restart = lib.mkOverride 500 "always"; };
    after = [ "podman-network-nixarr_default.service" ];
    requires = [ "podman-network-nixarr_default.service" ];
    partOf = [ "podman-compose-nixarr-root.target" ];
    wantedBy = [ "podman-compose-nixarr-root.target" ];
  };

  virtualisation.oci-containers.containers."radarr" = {
    # Check linuxserver/radarr for the latest stable tag
    image = "linuxserver/radarr:5.8.3"; # Example, use current stable tag
    environment = {
      PGID = "1000";
      PUID = "1000";
      TZ = "America/Bogota";
    };
    volumes = [
      # Downloads Path (Host) -> /downloads (Container) - ASSUMED UNCHANGED
      "/home/danielgm/Documents/Services/nixarr/media/downloads:/downloads:rw"
      # Config Path - Remains the same
      "/home/danielgm/Documents/Services/nixarr/media/radarr:/config:rw"
      # --- CHANGED Movie Library Path ---
      "/home/danielgm/Media/movies:/movies:rw" # Host path updated
    ];
    ports = [ "7878:7878/tcp" ];
    log-driver = "journald";
    extraOptions = [
      "--network-alias=radarr"
      "--network=nixarr_default"
    ];
  };
  systemd.services."podman-radarr" = {
    serviceConfig = { Restart = lib.mkOverride 500 "always"; };
    after = [ "podman-network-nixarr_default.service" ];
    requires = [ "podman-network-nixarr_default.service" ];
    partOf = [ "podman-compose-nixarr-root.target" ];
    wantedBy = [ "podman-compose-nixarr-root.target" ];
  };

  virtualisation.oci-containers.containers."sonarr" = {
    # Check linuxserver/sonarr for the latest stable tag (v4 recommended)
    image = "linuxserver/sonarr:4.0.8"; # Example, use current stable tag
    environment = {
      PGID = "1000";
      PUID = "1000";
      TZ = "America/Bogota";
    };
    volumes = [
      # Downloads Path (Host) -> /downloads (Container) - ASSUMED UNCHANGED
      "/home/danielgm/Documents/Services/nixarr/media/downloads:/downloads:rw"
      # Config Path - Remains the same
      "/home/danielgm/Documents/Services/nixarr/media/sonarr:/config:rw"
      # --- CHANGED TV Library Path ---
      "/home/danielgm/Media/tv:/tv:rw"          # Host path updated
      # --- CHANGED Anime Library Path ---
      "/home/danielgm/Media/anime:/anime:rw"      # Host path updated
    ];
    ports = [ "8989:8989/tcp" ];
    log-driver = "journald";
    extraOptions = [
      "--network-alias=sonarr"
      "--network=nixarr_default"
    ];
  };
  systemd.services."podman-sonarr" = {
    serviceConfig = { Restart = lib.mkOverride 500 "always"; };
    after = [ "podman-network-nixarr_default.service" ];
    requires = [ "podman-network-nixarr_default.service" ];
    partOf = [ "podman-compose-nixarr-root.target" ];
    wantedBy = [ "podman-compose-nixarr-root.target" ];
  };

  virtualisation.oci-containers.containers."lidarr" = {
    # !!! IMPORTANT: Replace <latest-stable-lidarr-tag> with the actual latest stable version tag !!!
    image = "lscr.io/linuxserver/lidarr:latest"; # e.g., linuxserver/lidarr:2.7.2
    environment = {
      PGID = "1000";
      PUID = "1000";
      TZ = "America/Bogota";
    };
    volumes = [
      # Config Path - Remains the same
      "/home/danielgm/Documents/Services/nixarr/media/lidarr:/config:rw"
      # Downloads Path (Host) -> /downloads (Container) - ASSUMED UNCHANGED
      "/home/danielgm/Documents/Services/nixarr/media/downloads:/downloads:rw"
      # --- CHANGED Music Library Path ---
      "/home/danielgm/Media/music:/music:rw"      # Host path updated
    ];
    ports = [ "8686:8686/tcp" ];
    log-driver = "journald";
    extraOptions = [
      "--network-alias=lidarr"
      "--network=nixarr_default"
    ];
  };
  systemd.services."podman-lidarr" = {
    serviceConfig = { Restart = lib.mkOverride 500 "always"; };
    after = [ "podman-network-nixarr_default.service" ];
    requires = [ "podman-network-nixarr_default.service" ];
    partOf = [ "podman-compose-nixarr-root.target" ];
    wantedBy = [ "podman-compose-nixarr-root.target" ];
  };

  virtualisation.oci-containers.containers."bazarr" = {
    # !!! IMPORTANT: Replace <latest-stable-bazarr-tag> with the actual latest stable version tag !!!
    image = "lscr.io/linuxserver/bazarr:latest";
    environment = {
      PGID = "1000";
      PUID = "1000";
      TZ = "America/Bogota";
    };
    volumes = [
      # Config Path - Remains the same
      "/home/danielgm/Documents/Services/nixarr/media/bazarr:/config:rw"
      # --- CHANGED Media Paths for Bazarr to Scan ---
      "/home/danielgm/Media/movies:/movies:rw" # Host path updated
      "/home/danielgm/Media/tv:/tv:rw"          # Host path updated
      "/home/danielgm/Media/anime:/anime:rw"      # Host path updated
    ];
    ports = [ "6767:6767/tcp" ];
    log-driver = "journald";
    extraOptions = [
      "--network-alias=bazarr"
      "--network=nixarr_default"
    ];
  };
  systemd.services."podman-bazarr" = {
    serviceConfig = { Restart = lib.mkOverride 500 "always"; };
    after = [ "podman-network-nixarr_default.service" ];
    requires = [ "podman-network-nixarr_default.service" ];
    partOf = [ "podman-compose-nixarr-root.target" ];
    wantedBy = [ "podman-compose-nixarr-root.target" ];
  };

  virtualisation.oci-containers.containers."qbittorrent" = {
    # Check linuxserver/qbittorrent for the latest stable tag
    image = "linuxserver/qbittorrent:4.6.5"; # Example, use current stable tag
    environment = {
      PGID = "1000";
      PUID = "1000";
      TZ = "America/Bogota";
    };
    volumes = [
      # Downloads Path (Host) -> /downloads (Container) - ASSUMED UNCHANGED
      "/home/danielgm/Documents/Services/nixarr/media/downloads:/downloads:rw"
      # Config Path - Remains the same (using app name for consistency)
      "/home/danielgm/Documents/Services/nixarr/media/qbittorrent:/config:rw"
    ];
    ports = [
      "8080:8080/tcp" # Web UI
      "6881:6881/tcp" # Default Torrenting Port (TCP)
      "6881:6881/udp" # Default Torrenting Port (UDP)
    ];
    log-driver = "journald";
    extraOptions = [
      "--network-alias=qbittorrent"
      "--network=nixarr_default"
    ];
  };
  systemd.services."podman-qbittorrent" = {
    serviceConfig = { Restart = lib.mkOverride 500 "always"; };
    after = [ "podman-network-nixarr_default.service" ];
    requires = [ "podman-network-nixarr_default.service" ];
    partOf = [ "podman-compose-nixarr-root.target" ];
    wantedBy = [ "podman-compose-nixarr-root.target" ];
  };

  virtualisation.oci-containers.containers."overseerr" = {
    image = "lscr.io/linuxserver/overseerr:latest";
    environment = {
      PGID = "1000";
      PUID = "1000";
      TZ = "America/Bogota";
    };
    volumes = [
      # Config Path
      "/home/danielgm/Documents/Services/nixarr/media/overseerr:/config:rw"
    ];
    ports = [ "5055:5055/tcp" ];
    log-driver = "journald";
    extraOptions = [
      "--network-alias=overseerr"
      "--network=nixarr_default"
    ];
  };
  systemd.services."podman-overseerr" = {
    serviceConfig = { Restart = lib.mkOverride 500 "always"; };
    after = [ "podman-network-nixarr_default.service" ];
    requires = [ "podman-network-nixarr_default.service" ];
    partOf = [ "podman-compose-nixarr-root.target" ];
    wantedBy = [ "podman-compose-nixarr-root.target" ];
  };

  # Networks
  systemd.services."podman-network-nixarr_default" = {
    path = [ pkgs.podman ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStop = ''
        if ${pkgs.podman}/bin/podman network exists nixarr_default; then
          ${pkgs.podman}/bin/podman network rm -f nixarr_default
        fi
      '';
    };
    script = ''
      ${pkgs.podman}/bin/podman network inspect nixarr_default >/dev/null 2>&1 || ${pkgs.podman}/bin/podman network create nixarr_default
    '';
    partOf = [ "podman-compose-nixarr-root.target" ];
    wantedBy = [ "podman-compose-nixarr-root.target" ];
  };

  # Root service
  systemd.targets."podman-compose-nixarr-root" = {
    unitConfig = {
      Description = "Root target for nixarr podman containers.";
      After = "network-online.target podman-network-nixarr_default.service";
      Wants = "network-online.target";
    };
    wantedBy = [ "multi-user.target" ];
  };
}
