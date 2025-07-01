# services/duckdb-container.nix
{ pkgs, lib, config, ... }:

{
  # Create a custom DuckDB container image
  virtualisation.oci-containers.containers."duckdb-server" = {
    image = "alpine:latest";
    
    # Start DuckDB with UI and keep it running
    cmd = [ 
      "/bin/sh" 
      "-c" 
      "cd /data && echo 'install ui; load ui; call start_ui();' | /usr/local/bin/duckdb -persist && tail -f /dev/null"
    ];
    
    environment = {
      "SSL_CERT_FILE" = "/etc/ssl/certs/ca-certificates.crt";
    };
    
    volumes = [
      # Persistent database storage
      "/home/danielgm/Documents/Services/duckdb/data:/data:rw,z"
      # Mount the DuckDB binary (built with our wrapper)
      "${pkgs.duckdb-with-extensions}/bin/duckdb:/usr/local/bin/duckdb:ro"
      # Mount SSL certificates
      "${pkgs.cacert}/etc/ssl/certs:/etc/ssl/certs:ro"
    ];
    
    ports = [
      "4213:4213/tcp"  # DuckDB UI port
    ];
    
    log-driver = "journald";
    
    extraOptions = [
      "--network-alias=duckdb"
      "--network=services_network"
    ];
  };
  
  systemd.services."podman-duckdb-server" = {
    serviceConfig = {
      Restart = lib.mkOverride 90 "always";
      RestartSec = "10s";
    };
    after = [
      "podman-network-services_network.service"
    ];
    requires = [
      "podman-network-services_network.service"
    ];
    partOf = [
      "podman-compose-services-root.target"
    ];
    wantedBy = [
      "podman-compose-services-root.target"
    ];
  };

  # Add to your existing network or create a new one
  systemd.services."podman-network-services_network" = {
    path = [ pkgs.podman ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStop = "podman network rm -f services_network";
    };
    script = ''
      podman network inspect services_network || podman network create services_network --driver=bridge
    '';
    partOf = [ "podman-compose-services-root.target" ];
    wantedBy = [ "podman-compose-services-root.target" ];
  };

  # Root service
  systemd.targets."podman-compose-services-root" = {
    unitConfig = {
      Description = "Root target for services.";
    };
    wantedBy = [ "multi-user.target" ];
  };
}
