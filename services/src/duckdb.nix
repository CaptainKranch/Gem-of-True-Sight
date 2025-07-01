# services/src/duckdb.nix
{ pkgs, lib, config, ... }:

{
  # Ensure data directory exists
  systemd.tmpfiles.rules = [
    "d /home/danielgm/Documents/Services/duckdb/data 0755 danielgm users -"
  ];

  # Create startup script
  environment.etc."duckdb/start-duckdb.sh" = {
    mode = "0755";
    text = ''
      #!/bin/bash
      set -e
      
      # Install required packages if not already installed
      if ! command -v wget &> /dev/null; then
        apt-get update
        apt-get install -y wget unzip ca-certificates netcat-traditional
      fi
      
      # Set up SSL certificates
      export SSL_CERT_FILE=/etc/ssl/certs/ca-certificates.crt
      
      # Download DuckDB if not exists
      if [ ! -f /data/duckdb ]; then
        echo "Downloading DuckDB..."
        cd /tmp
        wget https://github.com/duckdb/duckdb/releases/download/v1.3.1/duckdb_cli-linux-amd64.zip
        unzip duckdb_cli-linux-amd64.zip
        mv duckdb /data/duckdb
        chmod +x /data/duckdb
        rm duckdb_cli-linux-amd64.zip
      fi
      
      # Start DuckDB with UI in a screen-like fashion
      cd /data
      echo "Starting DuckDB UI..."
      
      # Use expect or similar to keep DuckDB interactive
      # For now, let's try a different approach with a background process
      (
        sleep 2
        echo "INSTALL ui;"
        echo "LOAD ui;"
        echo "CALL start_ui(bind='0.0.0.0', port=4213);"
        echo "-- Keep alive"
        while true; do
          sleep 3600
          echo "SELECT 'keepalive' WHERE 1=0;"
        done
      ) | /data/duckdb /data/database.duckdb &
      
      # Wait a bit for startup
      sleep 10
      
      # Check if port is listening
      echo "Checking if DuckDB UI is running..."
      nc -z 0.0.0.0 4213 && echo "DuckDB UI is running on port 4213" || echo "Failed to start UI"
      
      # Keep the container running
      echo "Container is running. DuckDB UI should be at http://localhost:4213"
      tail -f /dev/null
    '';
  };

  # DuckDB Container
  virtualisation.oci-containers.containers."duckdb-server" = {
    image = "ubuntu:22.04";
    
    cmd = [ "/etc/duckdb/start-duckdb.sh" ];
    
    volumes = [
      # Persistent storage
      "/home/danielgm/Documents/Services/duckdb/data:/data:rw"
      # Mount the startup script
      "/etc/duckdb/start-duckdb.sh:/etc/duckdb/start-duckdb.sh:ro"
    ];
    
    ports = [
      "4213:4213/tcp"  # DuckDB UI port
    ];
    
    log-driver = "journald";
    
    extraOptions = [
      "--network-alias=duckdb"
      "--network=minio_minionetwork"
    ];
  };
  
  systemd.services."podman-duckdb-server" = {
    serviceConfig = {
      Restart = lib.mkOverride 90 "always";
      RestartSec = "10s";
    };
    after = [
      "podman-network-minio_minionetwork.service"
    ];
    requires = [
      "podman-network-minio_minionetwork.service"
    ];
    partOf = [
      "podman-compose-duckdb-root.target"
    ];
    wantedBy = [
      "podman-compose-duckdb-root.target"
    ];
  };

  # Root service for DuckDB
  systemd.targets."podman-compose-duckdb-root" = {
    unitConfig = {
      Description = "Root target for DuckDB container.";
    };
    wantedBy = [ "multi-user.target" ];
  };
}
