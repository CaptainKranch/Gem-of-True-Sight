{ pkgs, lib, ... }:

{
  # Service to build CloudBeaver image with DuckDB driver
  systemd.services.build-cloudbeaver-duckdb = {
    description = "Build CloudBeaver with DuckDB driver";
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    path = [ pkgs.podman pkgs.buildah ];
    script = ''
      # Build custom CloudBeaver image with DuckDB driver
      DOCKERFILE_PATH="/home/danielgm/.config/nix/Gem-of-True-Sight/services/src/Dockerfile.cloudbeaver"
      
      # Check if image already exists
      if ! podman image exists localhost/cloudbeaver-duckdb:25.1.1-duckdb-1.3.0.0; then
        echo "Building CloudBeaver with DuckDB driver..."
        echo "Using Dockerfile: $DOCKERFILE_PATH"
        podman build -f "$DOCKERFILE_PATH" -t localhost/cloudbeaver-duckdb:25.1.1-duckdb-1.3.0.0 /home/danielgm/.config/nix/palantir/services/src
        echo "CloudBeaver with DuckDB driver built successfully"
      else
        echo "CloudBeaver with DuckDB driver image already exists"
      fi
    '';
  };
}
