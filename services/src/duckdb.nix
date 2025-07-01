# services/src/duckdb.nix
{ pkgs, lib, config, ... }:

{
  # Ensure data directory exists
  systemd.tmpfiles.rules = [
    "d /home/danielgm/Documents/Services/duckdb/data 0755 danielgm users -"
  ];

  # DuckDB Container - Using Ubuntu instead of Alpine for glibc compatibility
  virtualisation.oci-containers.containers."duckdb-server" = {
    image = "ubuntu:22.04";
    
    # Download DuckDB and start with UI
    cmd = [ 
      "/bin/bash" 
      "-c" 
      ''
        # Install required packages
        apt-get update && apt-get install -y wget unzip ca-certificates
        
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
        
        # Start DuckDB with UI
        cd /data
        echo "Starting DuckDB UI..."
        
        # Create a script to keep DuckDB running
        cat > /data/start-ui.sql << 'EOF'
        INSTALL ui;
        LOAD ui;
        CALL start_ui();
        -- Keep the session alive
        SELECT 'DuckDB UI started at http://localhost:4213' as status;
        EOF
        
        # Start DuckDB with the database file
        echo "Starting DuckDB with UI extension..."
        /data/duckdb /data/database.duckdb < /data/start-ui.sql &
        
        # Give it a moment to start
        sleep 5
        
        # Keep container running
        echo "DuckDB UI should be available at http://localhost:4213"
        echo "Container is running. Press Ctrl+C to stop."
        tail -f /dev/null
      ''
    ];
    
    volumes = [
      # Persistent storage for database and duckdb binary
      "/home/danielgm/Documents/Services/duckdb/data:/data:rw"
    ];
    
    ports = [
      "4213:4213/tcp"  # DuckDB UI port
    ];
    
    log-driver = "journald";
    
    extraOptions = [
      "--network-alias=duckdb"
      "--network=minio_minionetwork"  # Use your existing network
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
