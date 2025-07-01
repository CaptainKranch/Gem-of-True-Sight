# services/src/duckdb.nix
{ pkgs, lib, config, ... }:

{
  # Ensure data directory exists
  systemd.tmpfiles.rules = [
    "d /home/danielgm/Documents/Services/duckdb/data 0755 danielgm users -"
  ];

  # Create a Python script to run DuckDB with UI
  environment.etc."duckdb/duckdb-server.py" = {
    mode = "0755";
    text = ''
      #!/usr/bin/env python3
      import subprocess
      import time
      import os
      
      # Download DuckDB if needed
      if not os.path.exists('/data/duckdb'):
          print("Downloading DuckDB...")
          subprocess.run(['wget', 'https://github.com/duckdb/duckdb/releases/download/v1.3.1/duckdb_cli-linux-amd64.zip'], cwd='/tmp')
          subprocess.run(['unzip', 'duckdb_cli-linux-amd64.zip'], cwd='/tmp')
          subprocess.run(['mv', '/tmp/duckdb', '/data/duckdb'])
          subprocess.run(['chmod', '+x', '/data/duckdb'])
          subprocess.run(['rm', '/tmp/duckdb_cli-linux-amd64.zip'])
      
      # Start DuckDB with UI using subprocess
      print("Starting DuckDB UI...")
      
      # Create the initialization commands
      init_commands = """
      INSTALL ui;
      LOAD ui;
      CALL start_ui();
      SELECT 'UI started, keeping session alive...';
      """
      
      # Start DuckDB process
      proc = subprocess.Popen(
          ['/data/duckdb', '/data/database.duckdb'],
          stdin=subprocess.PIPE,
          stdout=subprocess.PIPE,
          stderr=subprocess.STDOUT,
          text=True,
          bufsize=0
      )
      
      # Send initialization commands
      proc.stdin.write(init_commands)
      proc.stdin.flush()
      
      # Keep the process running and print output
      print("DuckDB process started. Output:")
      while True:
          output = proc.stdout.readline()
          if output:
              print(output.strip())
          time.sleep(0.1)
    '';
  };

  # Alternative: Create a simple HTTP server that proxies to DuckDB UI
  environment.etc."duckdb/start-duckdb.sh" = {
    mode = "0755";
    text = ''
      #!/bin/bash
      set -e
      
      # Install required packages
      apt-get update
      DEBIAN_FRONTEND=noninteractive apt-get install -y \
        wget unzip ca-certificates python3 python3-pip netcat-traditional
      
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
      
      cd /data
      
      # Method 1: Try running DuckDB in a more controlled way
      echo "Starting DuckDB with UI extension..."
      
      # Create a named pipe for input
      mkfifo /tmp/duckdb_input
      
      # Start DuckDB with the named pipe as input
      /data/duckdb /data/database.duckdb < /tmp/duckdb_input &
      DUCKDB_PID=$!
      
      # Send commands to initialize UI
      (
        echo "INSTALL ui;"
        echo "LOAD ui;"
        echo "CALL start_ui();"
        echo "SELECT 'UI should be running on port 4213';"
        # Keep the pipe open
        while true; do
          sleep 3600
        done
      ) > /tmp/duckdb_input &
      
      # Give it time to start
      sleep 10
      
      # Check what's listening
      echo "=== Checking network connections ==="
      ss -tlnp || netstat -tlnp || true
      
      # Check if DuckDB process is running
      if ps -p $DUCKDB_PID > /dev/null; then
        echo "DuckDB process is running (PID: $DUCKDB_PID)"
      else
        echo "DuckDB process failed to start"
      fi
      
      # Alternative: If the UI is only accessible on localhost, create a simple proxy
      if nc -z localhost 4213; then
        echo "UI is running on localhost:4213"
        # You could add a reverse proxy here if needed
      fi
      
      # Keep container running
      echo "Container is running. Check http://localhost:4213"
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
      # Mount scripts
      "/etc/duckdb:/etc/duckdb:ro"
    ];
    
    ports = [
      "4213:4213/tcp"  # DuckDB UI port
    ];
    
    log-driver = "journald";
    
    # Use host networking to avoid port binding issues
    extraOptions = [
      "--network=host"
    ];
  };
  
  systemd.services."podman-duckdb-server" = {
    serviceConfig = {
      Restart = lib.mkOverride 90 "always";
      RestartSec = "10s";
    };
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
