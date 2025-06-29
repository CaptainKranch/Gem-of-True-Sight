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
  virtualisation.oci-containers.containers."dba-cloudbeaver" = {
    image = "localhost/cloudbeaver-duckdb:25.1.1-duckdb-1.3.0.0";
    environment = {
      "CB_ADMIN_PASSWORD" = "password123";
      "CB_ADMIN_USER" = "admin";
      "CB_SERVER_NAME" = "CloudBeaver";
    };
    volumes = [
      "/home/danielgm/Documents/Services/cloudbeaver/data:/opt/cloudbeaver/workspace:rw"
    ];
    ports = [
      "8978:8978/tcp"
    ];
    log-driver = "journald";
    cmd = [ 
      "sh" 
      "-c" 
      "chown -R dbeaver:dbeaver /opt/cloudbeaver/workspace && exec ./run-server.sh" 
    ];
    extraOptions = [
      "--network-alias=cloudbeaver"
      "--network=dba_default"
    ];
  };
  systemd.services."podman-dba-cloudbeaver" = {
    serviceConfig = {
      Restart = lib.mkOverride 90 "no";
    };
    after = [
      "podman-network-dba_default.service"
      "podman-volume-dba_cloudbeaver_data.service"
      "build-cloudbeaver-duckdb.service"
    ];
    requires = [
      "podman-network-dba_default.service"
      "podman-volume-dba_cloudbeaver_data.service"
      "build-cloudbeaver-duckdb.service"
    ];
    partOf = [
      "podman-compose-dba-root.target"
    ];
    wantedBy = [
      "podman-compose-dba-root.target"
    ];
  };

  # Networks
  systemd.services."podman-network-dba_default" = {
    path = [ pkgs.podman ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStop = "podman network rm -f dba_default";
    };
    script = ''
      podman network inspect dba_default || podman network create dba_default
    '';
    partOf = [ "podman-compose-dba-root.target" ];
    wantedBy = [ "podman-compose-dba-root.target" ];
  };

  # Volumes
  systemd.services."podman-volume-dba_cloudbeaver_data" = {
    path = [ pkgs.podman ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      podman volume inspect dba_cloudbeaver_data || podman volume create dba_cloudbeaver_data
    '';
    partOf = [ "podman-compose-dba-root.target" ];
    wantedBy = [ "podman-compose-dba-root.target" ];
  };

  # Root service
  # When started, this will automatically create all resources and start
  # the containers. When stopped, this will teardown all resources.
  systemd.targets."podman-compose-dba-root" = {
    unitConfig = {
      Description = "Root target generated by compose2nix.";
    };
    wantedBy = [ "multi-user.target" ];
  };
}
