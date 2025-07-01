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
        apt-get install -y wget unzip ca-certificates netcat-traditional screen
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
      
      # Start DuckDB in screen session
      cd /data
      echo "Starting DuckDB UI..."
      
      # Create initialization script
      cat > /data/init.sql << 'EOF'
      INSTALL ui;
      LOAD ui;
      CALL start_ui();
      SELECT 'DuckDB UI is running at http://0.0.0.0:4213' as info;
      EOF
      
      # Start DuckDB in a screen session to keep it interactive
      screen -dmS duckdb_session bash -c "
        cd /data
        /data/duckdb /data/database.duckdb < /data/init.sql
        # After init, keep DuckDB running interactively
        exec /data/duckdb /data/database.duckdb
      "
      
      # Wait for startup
      echo "Waiting for DuckDB to start..."
      sleep 10
      
      # Check if screen session is running
      screen -list | grep duckdb_session && echo "DuckDB session is running" || echo "Failed to start DuckDB session"
      
      # Try to check if port is open
      for i in {1..10}; do
        if nc -z localhost 4213 2>/dev/null; then
          echo "DuckDB UI is accessible on port 4213"
          break
        else
          echo "Waiting for UI to start... (attempt $i/10)"
          sleep 2
        fi
      done
      
      # Show the screen session logs
      echo "=== DuckDB Logs ==="
      screen -S duckdb_session -X hardcopy /tmp/screen.log
      cat /tmp/screen.log || true
      echo "=================="
      
      # Keep the container running
      echo "Container is running. DuckDB UI should be at http://localhost:4213"
      echo "To attach to DuckDB session, run: podman exec -it duckdb-server screen -r duckdb_session"
      tail -f /dev/null
    '';
  };

  # DuckDB Container
  virtualisation.oci-containers.containers."duckdb-server" = {
    image = "ubuntu:22.04";
    
    cmd = [ "/etc/duckdb/start-duckdb.sh" ];
    
    environment = {
      "DEBIAN_FRONTEND" = "noninteractive";
    };
    
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
