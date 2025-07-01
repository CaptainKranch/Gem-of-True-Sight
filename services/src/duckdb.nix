# services/src/duckdb.nix
{ pkgs, lib, config, ... }:

{
  # Ensure data directory exists
  systemd.tmpfiles.rules = [
    "d /home/danielgm/Documents/Services/duckdb/data 0755 danielgm users -"
  ];

  # DuckDB Container
  virtualisation.oci-containers.containers."duckdb-server" = {
    image = "alpine:latest";
    
    # Download DuckDB and start with UI
    cmd = [ 
      "/bin/sh" 
      "-c" 
      ''
        # Install required packages
        apk add --no-cache wget ca-certificates
        
        # Download DuckDB if not exists
        if [ ! -f /data/duckdb ]; then
          echo "Downloading DuckDB..."
          wget https://github.com/duckdb/duckdb/releases/download/v1.3.1/duckdb_cli-linux-amd64.zip
          unzip duckdb_cli-linux-amd64.zip
          mv duckdb /data/duckdb
          chmod +x /data/duckdb
          rm duckdb_cli-linux-amd64.zip
        fi
        
        # Start DuckDB with UI
        cd /data
        echo "Starting DuckDB UI..."
        /data/duckdb -persist /data/database.duckdb << EOF
        INSTALL ui;
        LOAD ui;
        CALL start_ui();
        EOF
        
        # Keep container running
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
