# Auto-generated using compose2nix v0.3.2-pre.
{ pkgs, lib, config, ... }:

{
  # Runtime
  virtualisation.podman = {
    enable = true;
    autoPrune.enable = true;
    dockerCompat = true;
  };

  # Enable container name DNS for all Podman networks.
  networking.firewall.interfaces = let
    matchAll = if !config.networking.nftables.enable then "podman+" else "podman*";
  in {
    "${matchAll}".allowedUDPPorts = [ 53 ];
  };

  virtualisation.oci-containers.backend = "podman";

  # Containers
  virtualisation.oci-containers.containers."paperless-broker" = {
    image = "docker.io/library/redis:7";
    volumes = [
      "paperless_redisdata:/data:rw"
    ];
    log-driver = "journald";
    extraOptions = [
      "--network-alias=broker"
      "--network=paperless_default"
    ];
  };
  systemd.services."podman-paperless-broker" = {
    serviceConfig = {
      Restart = lib.mkOverride 90 "always";
    };
    after = [
      "podman-network-paperless_default.service"
      "podman-volume-paperless_redisdata.service"
    ];
    requires = [
      "podman-network-paperless_default.service"
      "podman-volume-paperless_redisdata.service"
    ];
    partOf = [
      "podman-compose-paperless-root.target"
    ];
    wantedBy = [
      "podman-compose-paperless-root.target"
    ];
  };
  virtualisation.oci-containers.containers."paperless-db" = {
    image = "docker.io/library/mariadb:11";
    environment = {
      "MARIADB_DATABASE" = "paperless";
      "MARIADB_HOST" = "paperless";
      "MARIADB_PASSWORD" = "paperless";
      "MARIADB_ROOT_PASSWORD" = "paperless";
      "MARIADB_USER" = "paperless";
    };
    volumes = [
      "paperless_dbdata:/var/lib/mysql:rw"
    ];
    log-driver = "journald";
    extraOptions = [
      "--network-alias=db"
      "--network=paperless_default"
    ];
  };
  systemd.services."podman-paperless-db" = {
    serviceConfig = {
      Restart = lib.mkOverride 90 "always";
    };
    after = [
      "podman-network-paperless_default.service"
      "podman-volume-paperless_dbdata.service"
    ];
    requires = [
      "podman-network-paperless_default.service"
      "podman-volume-paperless_dbdata.service"
    ];
    partOf = [
      "podman-compose-paperless-root.target"
    ];
    wantedBy = [
      "podman-compose-paperless-root.target"
    ];
  };
  virtualisation.oci-containers.containers."paperless-webserver" = {
    image = "ghcr.io/paperless-ngx/paperless-ngx:latest";
    environment = {
      "PAPERLESS_DBENGINE" = "mariadb";
      "PAPERLESS_DBHOST" = "db";
      "PAPERLESS_DBPASS" = "paperless";
      "PAPERLESS_DBPORT" = "3306";
      "PAPERLESS_DBUSER" = "paperless";
      "PAPERLESS_REDIS" = "redis://broker:6379";
    };
    volumes = [
      "/home/danielgm/Documents/Services/paperless/consume:/usr/src/paperless/consume:rw"
      "/home/danielgm/Documents/Services/paperless/export:/usr/src/paperless/export:rw"
      "paperless_data:/usr/src/paperless/data:rw"
      "paperless_media:/usr/src/paperless/media:rw"
    ];
    ports = [
      "8000:8000/tcp"
    ];
    dependsOn = [
      "paperless-broker"
      "paperless-db"
    ];
    log-driver = "journald";
    extraOptions = [
      "--network-alias=webserver"
      "--network=paperless_default"
    ];
  };
  systemd.services."podman-paperless-webserver" = {
    serviceConfig = {
      Restart = lib.mkOverride 90 "always";
    };
    after = [
      "podman-network-paperless_default.service"
      "podman-volume-paperless_data.service"
      "podman-volume-paperless_media.service"
    ];
    requires = [
      "podman-network-paperless_default.service"
      "podman-volume-paperless_data.service"
      "podman-volume-paperless_media.service"
    ];
    partOf = [
      "podman-compose-paperless-root.target"
    ];
    wantedBy = [
      "podman-compose-paperless-root.target"
    ];
  };

  # Networks
  systemd.services."podman-network-paperless_default" = {
    path = [ pkgs.podman ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStop = "podman network rm -f paperless_default";
    };
    script = ''
      podman network inspect paperless_default || podman network create paperless_default
    '';
    partOf = [ "podman-compose-paperless-root.target" ];
    wantedBy = [ "podman-compose-paperless-root.target" ];
  };

  # Volumes
  systemd.services."podman-volume-paperless_data" = {
    path = [ pkgs.podman ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      podman volume inspect paperless_data || podman volume create paperless_data
    '';
    partOf = [ "podman-compose-paperless-root.target" ];
    wantedBy = [ "podman-compose-paperless-root.target" ];
  };
  systemd.services."podman-volume-paperless_dbdata" = {
    path = [ pkgs.podman ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      podman volume inspect paperless_dbdata || podman volume create paperless_dbdata
    '';
    partOf = [ "podman-compose-paperless-root.target" ];
    wantedBy = [ "podman-compose-paperless-root.target" ];
  };
  systemd.services."podman-volume-paperless_media" = {
    path = [ pkgs.podman ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      podman volume inspect paperless_media || podman volume create paperless_media
    '';
    partOf = [ "podman-compose-paperless-root.target" ];
    wantedBy = [ "podman-compose-paperless-root.target" ];
  };
  systemd.services."podman-volume-paperless_redisdata" = {
    path = [ pkgs.podman ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      podman volume inspect paperless_redisdata || podman volume create paperless_redisdata
    '';
    partOf = [ "podman-compose-paperless-root.target" ];
    wantedBy = [ "podman-compose-paperless-root.target" ];
  };

  # Root service
  # When started, this will automatically create all resources and start
  # the containers. When stopped, this will teardown all resources.
  systemd.targets."podman-compose-paperless-root" = {
    unitConfig = {
      Description = "Root target generated by compose2nix.";
    };
    wantedBy = [ "multi-user.target" ];
  };
}
