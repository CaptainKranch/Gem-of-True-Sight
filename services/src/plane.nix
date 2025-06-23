# Auto-generated using compose2nix v0.3.2-pre with fixes for port conflicts
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
  virtualisation.oci-containers.containers."plane-admin" = {
    image = "artifacts.plane.so/makeplane/plane-admin:v0.26.1";
    environmentFiles = [
      "/home/danielgm/Documents/Services/plane/plane-app/plane.env"
    ];
    cmd = [ "node" "admin/server.js" "admin" ];
    dependsOn = [
      "plane-api"
      "plane-web"
    ];
    log-driver = "journald";
    extraOptions = [
      "--network-alias=admin"
      "--network=plane_default"
    ];
  };
  systemd.services."podman-plane-admin" = {
    serviceConfig = {
      Restart = lib.mkOverride 90 "on-failure";
      RestartSec = lib.mkOverride 90 0;
    };
    after = [
      "podman-network-plane_default.service"
    ];
    requires = [
      "podman-network-plane_default.service"
    ];
    partOf = [
      "podman-compose-plane-root.target"
    ];
    wantedBy = [
      "podman-compose-plane-root.target"
    ];
  };
  virtualisation.oci-containers.containers."plane-api" = {
    image = "artifacts.plane.so/makeplane/plane-backend:v0.26.1";
    environment = {
      "AMQP_URL" = "amqp://plane:plane@plane-mq:5672/plane";
      "API_KEY_RATE_LIMIT" = "60/minute";
      "AWS_ACCESS_KEY_ID" = "access-key";
      "AWS_REGION" = "";
      "AWS_S3_BUCKET_NAME" = "uploads";
      "AWS_S3_ENDPOINT_URL" = "http://plane-minio:9000";
      "AWS_SECRET_ACCESS_KEY" = "secret-key";
      "BUCKET_NAME" = "uploads";
      "CORS_ALLOWED_ORIGINS" = "http://localhost:8081";
      "DATABASE_URL" = "postgresql://plane:plane@plane-db/plane";
      "DEBUG" = "0";
      "FILE_SIZE_LIMIT" = "5242880";
      "GUNICORN_WORKERS" = "1";
      "MINIO_ENDPOINT_SSL" = "0";
      "MINIO_ROOT_PASSWORD" = "secret-key";
      "MINIO_ROOT_USER" = "access-key";
      "NGINX_PORT" = "80";
      "PGDATA" = "/var/lib/postgresql/data";
      "PGDATABASE" = "plane";
      "PGHOST" = "plane-db";
      "POSTGRES_DB" = "plane";
      "POSTGRES_PASSWORD" = "plane";
      "POSTGRES_PORT" = "5432";
      "POSTGRES_USER" = "plane";
      "REDIS_HOST" = "plane-redis";
      "REDIS_PORT" = "6379";
      "REDIS_URL" = "redis://plane-redis:6379/";
      "SECRET_KEY" = "60gp0byfz2dvffa45cxl20p1scy9xbpf6d8c5y0geejgkyp1b5";
      "USE_MINIO" = "1";
      "WEB_URL" = "http://localhost:8081";
    };
    environmentFiles = [
      "/home/danielgm/Documents/Services/plane/plane-app/plane.env"
    ];
    volumes = [
      "plane_logs_api:/code/plane/logs:rw"
    ];
    cmd = [ "./bin/docker-entrypoint-api.sh" ];
    dependsOn = [
      "plane-plane-db"
      "plane-plane-mq"
      "plane-plane-redis"
    ];
    log-driver = "journald";
    extraOptions = [
      "--network-alias=api"
      "--network=plane_default"
    ];
    # Optional: Expose API directly for debugging
    # ports = [ "8000:8000/tcp" ];
  };
  systemd.services."podman-plane-api" = {
    serviceConfig = {
      Restart = lib.mkOverride 90 "on-failure";
      RestartSec = lib.mkOverride 90 0;
    };
    after = [
      "podman-network-plane_default.service"
      "podman-volume-plane_logs_api.service"
    ];
    requires = [
      "podman-network-plane_default.service"
      "podman-volume-plane_logs_api.service"
    ];
    partOf = [
      "podman-compose-plane-root.target"
    ];
    wantedBy = [
      "podman-compose-plane-root.target"
    ];
  };
  virtualisation.oci-containers.containers."plane-beat-worker" = {
    image = "artifacts.plane.so/makeplane/plane-backend:v0.26.1";
    environment = {
      "AMQP_URL" = "amqp://plane:plane@plane-mq:5672/plane";
      "API_KEY_RATE_LIMIT" = "60/minute";
      "AWS_ACCESS_KEY_ID" = "access-key";
      "AWS_REGION" = "";
      "AWS_S3_BUCKET_NAME" = "uploads";
      "AWS_S3_ENDPOINT_URL" = "http://plane-minio:9000";
      "AWS_SECRET_ACCESS_KEY" = "secret-key";
      "BUCKET_NAME" = "uploads";
      "CORS_ALLOWED_ORIGINS" = "http://localhost:8081";
      "DATABASE_URL" = "postgresql://plane:plane@plane-db/plane";
      "DEBUG" = "0";
      "FILE_SIZE_LIMIT" = "5242880";
      "GUNICORN_WORKERS" = "1";
      "MINIO_ENDPOINT_SSL" = "0";
      "MINIO_ROOT_PASSWORD" = "secret-key";
      "MINIO_ROOT_USER" = "access-key";
      "NGINX_PORT" = "80";
      "PGDATA" = "/var/lib/postgresql/data";
      "PGDATABASE" = "plane";
      "PGHOST" = "plane-db";
      "POSTGRES_DB" = "plane";
      "POSTGRES_PASSWORD" = "plane";
      "POSTGRES_PORT" = "5432";
      "POSTGRES_USER" = "plane";
      "REDIS_HOST" = "plane-redis";
      "REDIS_PORT" = "6379";
      "REDIS_URL" = "redis://plane-redis:6379/";
      "SECRET_KEY" = "60gp0byfz2dvffa45cxl20p1scy9xbpf6d8c5y0geejgkyp1b5";
      "USE_MINIO" = "1";
      "WEB_URL" = "http://localhost:8081";
    };
    environmentFiles = [
      "/home/danielgm/Documents/Services/plane/plane-app/plane.env"
    ];
    volumes = [
      "plane_logs_beat-worker:/code/plane/logs:rw"
    ];
    cmd = [ "./bin/docker-entrypoint-beat.sh" ];
    dependsOn = [
      "plane-api"
      "plane-plane-db"
      "plane-plane-mq"
      "plane-plane-redis"
    ];
    log-driver = "journald";
    extraOptions = [
      "--network-alias=beat-worker"
      "--network=plane_default"
    ];
  };
  systemd.services."podman-plane-beat-worker" = {
    serviceConfig = {
      Restart = lib.mkOverride 90 "on-failure";
      RestartSec = lib.mkOverride 90 0;
    };
    after = [
      "podman-network-plane_default.service"
      "podman-volume-plane_logs_beat-worker.service"
    ];
    requires = [
      "podman-network-plane_default.service"
      "podman-volume-plane_logs_beat-worker.service"
    ];
    partOf = [
      "podman-compose-plane-root.target"
    ];
    wantedBy = [
      "podman-compose-plane-root.target"
    ];
  };
  virtualisation.oci-containers.containers."plane-live" = {
    image = "artifacts.plane.so/makeplane/plane-live:v0.26.1";
    environment = {
      "API_BASE_URL" = "http://api:8000";
    };
    environmentFiles = [
      "/home/danielgm/Documents/Services/plane/plane-app/plane.env"
    ];
    cmd = [ "node" "live/dist/server.js" "live" ];
    dependsOn = [
      "plane-api"
      "plane-web"
    ];
    log-driver = "journald";
    extraOptions = [
      "--network-alias=live"
      "--network=plane_default"
    ];
  };
  systemd.services."podman-plane-live" = {
    serviceConfig = {
      Restart = lib.mkOverride 90 "on-failure";
      RestartSec = lib.mkOverride 90 0;
    };
    after = [
      "podman-network-plane_default.service"
    ];
    requires = [
      "podman-network-plane_default.service"
    ];
    partOf = [
      "podman-compose-plane-root.target"
    ];
    wantedBy = [
      "podman-compose-plane-root.target"
    ];
  };
  virtualisation.oci-containers.containers."plane-migrator" = {
    image = "artifacts.plane.so/makeplane/plane-backend:v0.26.1";
    environment = {
      "AMQP_URL" = "amqp://plane:plane@plane-mq:5672/plane";
      "API_KEY_RATE_LIMIT" = "60/minute";
      "AWS_ACCESS_KEY_ID" = "access-key";
      "AWS_REGION" = "";
      "AWS_S3_BUCKET_NAME" = "uploads";
      "AWS_S3_ENDPOINT_URL" = "http://plane-minio:9000";
      "AWS_SECRET_ACCESS_KEY" = "secret-key";
      "BUCKET_NAME" = "uploads";
      "CORS_ALLOWED_ORIGINS" = "http://localhost:8081";
      "DATABASE_URL" = "postgresql://plane:plane@plane-db/plane";
      "DEBUG" = "0";
      "FILE_SIZE_LIMIT" = "5242880";
      "GUNICORN_WORKERS" = "1";
      "MINIO_ENDPOINT_SSL" = "0";
      "MINIO_ROOT_PASSWORD" = "secret-key";
      "MINIO_ROOT_USER" = "access-key";
      "NGINX_PORT" = "80";
      "PGDATA" = "/var/lib/postgresql/data";
      "PGDATABASE" = "plane";
      "PGHOST" = "plane-db";
      "POSTGRES_DB" = "plane";
      "POSTGRES_PASSWORD" = "plane";
      "POSTGRES_PORT" = "5432";
      "POSTGRES_USER" = "plane";
      "REDIS_HOST" = "plane-redis";
      "REDIS_PORT" = "6379";
      "REDIS_URL" = "redis://plane-redis:6379/";
      "SECRET_KEY" = "60gp0byfz2dvffa45cxl20p1scy9xbpf6d8c5y0geejgkyp1b5";
      "USE_MINIO" = "1";
      "WEB_URL" = "http://localhost:8081";
    };
    environmentFiles = [
      "/home/danielgm/Documents/Services/plane/plane-app/plane.env"
    ];
    volumes = [
      "plane_logs_migrator:/code/plane/logs:rw"
    ];
    cmd = [ "./bin/docker-entrypoint-migrator.sh" ];
    dependsOn = [
      "plane-plane-db"
      "plane-plane-redis"
    ];
    log-driver = "journald";
    extraOptions = [
      "--network-alias=migrator"
      "--network=plane_default"
    ];
  };
  systemd.services."podman-plane-migrator" = {
    serviceConfig = {
      Restart = lib.mkOverride 90 "on-failure";
      RestartSec = lib.mkOverride 90 0;
    };
    after = [
      "podman-network-plane_default.service"
      "podman-volume-plane_logs_migrator.service"
    ];
    requires = [
      "podman-network-plane_default.service"
      "podman-volume-plane_logs_migrator.service"
    ];
    partOf = [
      "podman-compose-plane-root.target"
    ];
    wantedBy = [
      "podman-compose-plane-root.target"
    ];
  };
  virtualisation.oci-containers.containers."plane-plane-db" = {
    image = "postgres:15.7-alpine";
    environment = {
      "PGDATA" = "/var/lib/postgresql/data";
      "PGDATABASE" = "plane";
      "PGHOST" = "plane-db";
      "POSTGRES_DB" = "plane";
      "POSTGRES_PASSWORD" = "plane";
      "POSTGRES_PORT" = "5432";
      "POSTGRES_USER" = "plane";
    };
    environmentFiles = [
      "/home/danielgm/Documents/Services/plane/plane-app/plane.env"
    ];
    volumes = [
      "plane_pgdata:/var/lib/postgresql/data:rw"
    ];
    cmd = [ "postgres" "-c" "max_connections=1000" ];
    log-driver = "journald";
    extraOptions = [
      "--network-alias=plane-db"
      "--network=plane_default"
    ];
  };
  systemd.services."podman-plane-plane-db" = {
    serviceConfig = {
      Restart = lib.mkOverride 90 "on-failure";
      RestartSec = lib.mkOverride 90 0;
    };
    after = [
      "podman-network-plane_default.service"
      "podman-volume-plane_pgdata.service"
    ];
    requires = [
      "podman-network-plane_default.service"
      "podman-volume-plane_pgdata.service"
    ];
    partOf = [
      "podman-compose-plane-root.target"
    ];
    wantedBy = [
      "podman-compose-plane-root.target"
    ];
  };
  virtualisation.oci-containers.containers."plane-plane-minio" = {
    image = "minio/minio:latest";
    environment = {
      "MINIO_ROOT_PASSWORD" = "secret-key";
      "MINIO_ROOT_USER" = "access-key";
    };
    environmentFiles = [
      "/home/danielgm/Documents/Services/plane/plane-app/plane.env"
    ];
    volumes = [
      "plane_uploads:/export:rw"
    ];
    cmd = [ "server" "/export" "--console-address" ":9090" ];
    log-driver = "journald";
    extraOptions = [
      "--network-alias=plane-minio"
      "--network=plane_default"
    ];
  };
  systemd.services."podman-plane-plane-minio" = {
    serviceConfig = {
      Restart = lib.mkOverride 90 "on-failure";
      RestartSec = lib.mkOverride 90 0;
    };
    after = [
      "podman-network-plane_default.service"
      "podman-volume-plane_uploads.service"
    ];
    requires = [
      "podman-network-plane_default.service"
      "podman-volume-plane_uploads.service"
    ];
    partOf = [
      "podman-compose-plane-root.target"
    ];
    wantedBy = [
      "podman-compose-plane-root.target"
    ];
  };
  virtualisation.oci-containers.containers."plane-plane-mq" = {
    image = "rabbitmq:3.13.6-management-alpine";
    environment = {
      "RABBITMQ_DEFAULT_PASS" = "plane";
      "RABBITMQ_DEFAULT_USER" = "plane";
      "RABBITMQ_DEFAULT_VHOST" = "plane";
      "RABBITMQ_HOST" = "plane-mq";
      "RABBITMQ_PORT" = "5672";
      "RABBITMQ_VHOST" = "plane";
    };
    environmentFiles = [
      "/home/danielgm/Documents/Services/plane/plane-app/plane.env"
    ];
    volumes = [
      "plane_rabbitmq_data:/var/lib/rabbitmq:rw"
    ];
    log-driver = "journald";
    extraOptions = [
      "--network-alias=plane-mq"
      "--network=plane_default"
    ];
  };
  systemd.services."podman-plane-plane-mq" = {
    serviceConfig = {
      Restart = lib.mkOverride 90 "on-failure";
      RestartSec = lib.mkOverride 90 0;
    };
    after = [
      "podman-network-plane_default.service"
      "podman-volume-plane_rabbitmq_data.service"
    ];
    requires = [
      "podman-network-plane_default.service"
      "podman-volume-plane_rabbitmq_data.service"
    ];
    partOf = [
      "podman-compose-plane-root.target"
    ];
    wantedBy = [
      "podman-compose-plane-root.target"
    ];
  };
  virtualisation.oci-containers.containers."plane-plane-redis" = {
    image = "valkey/valkey:7.2.5-alpine";
    environmentFiles = [
      "/home/danielgm/Documents/Services/plane/plane-app/plane.env"
    ];
    volumes = [
      "plane_redisdata:/data:rw"
    ];
    log-driver = "journald";
    extraOptions = [
      "--network-alias=plane-redis"
      "--network=plane_default"
    ];
  };
  systemd.services."podman-plane-plane-redis" = {
    serviceConfig = {
      Restart = lib.mkOverride 90 "on-failure";
      RestartSec = lib.mkOverride 90 0;
    };
    after = [
      "podman-network-plane_default.service"
      "podman-volume-plane_redisdata.service"
    ];
    requires = [
      "podman-network-plane_default.service"
      "podman-volume-plane_redisdata.service"
    ];
    partOf = [
      "podman-compose-plane-root.target"
    ];
    wantedBy = [
      "podman-compose-plane-root.target"
    ];
  };
  virtualisation.oci-containers.containers."plane-proxy" = {
    image = "artifacts.plane.so/makeplane/plane-proxy:v0.26.1";
    environment = {
      "BUCKET_NAME" = "uploads";
      "FILE_SIZE_LIMIT" = "5242880";
      "NGINX_PORT" = "80";
    };
    environmentFiles = [
      "/home/danielgm/Documents/Services/plane/plane-app/plane.env"
    ];
    ports = [
      "8081:80/tcp"  # Changed from 80:80 to avoid conflict
    ];
    dependsOn = [
      "plane-api"
      "plane-space"
      "plane-web"
    ];
    log-driver = "journald";
    extraOptions = [
      "--network-alias=proxy"
      "--network=plane_default"
    ];
  };
  systemd.services."podman-plane-proxy" = {
    serviceConfig = {
      Restart = lib.mkOverride 90 "on-failure";
      RestartSec = lib.mkOverride 90 5;  # Give some time between restarts
    };
    after = [
      "podman-network-plane_default.service"
    ];
    requires = [
      "podman-network-plane_default.service"
    ];
    partOf = [
      "podman-compose-plane-root.target"
    ];
    wantedBy = [
      "podman-compose-plane-root.target"
    ];
  };
  virtualisation.oci-containers.containers."plane-space" = {
    image = "artifacts.plane.so/makeplane/plane-space:v0.26.1";
    environmentFiles = [
      "/home/danielgm/Documents/Services/plane/plane-app/plane.env"
    ];
    cmd = [ "node" "space/server.js" "space" ];
    dependsOn = [
      "plane-api"
      "plane-web"
      "plane-worker"
    ];
    log-driver = "journald";
    extraOptions = [
      "--network-alias=space"
      "--network=plane_default"
    ];
  };
  systemd.services."podman-plane-space" = {
    serviceConfig = {
      Restart = lib.mkOverride 90 "on-failure";
      RestartSec = lib.mkOverride 90 0;
    };
    after = [
      "podman-network-plane_default.service"
    ];
    requires = [
      "podman-network-plane_default.service"
    ];
    partOf = [
      "podman-compose-plane-root.target"
    ];
    wantedBy = [
      "podman-compose-plane-root.target"
    ];
  };
  virtualisation.oci-containers.containers."plane-web" = {
    image = "artifacts.plane.so/makeplane/plane-frontend:v0.26.1";
    environmentFiles = [
      "/home/danielgm/Documents/Services/plane/plane-app/plane.env"
    ];
    cmd = [ "node" "web/server.js" "web" ];
    dependsOn = [
      "plane-api"
      "plane-worker"
    ];
    log-driver = "journald";
    extraOptions = [
      "--network-alias=web"
      "--network=plane_default"
    ];
    # Optional: Expose web directly for debugging
    ports = [ "3001:3000/tcp" ];
  };
  systemd.services."podman-plane-web" = {
    serviceConfig = {
      Restart = lib.mkOverride 90 "on-failure";
      RestartSec = lib.mkOverride 90 0;
    };
    after = [
      "podman-network-plane_default.service"
    ];
    requires = [
      "podman-network-plane_default.service"
    ];
    partOf = [
      "podman-compose-plane-root.target"
    ];
    wantedBy = [
      "podman-compose-plane-root.target"
    ];
  };
  virtualisation.oci-containers.containers."plane-worker" = {
    image = "artifacts.plane.so/makeplane/plane-backend:v0.26.1";
    environment = {
      "AMQP_URL" = "amqp://plane:plane@plane-mq:5672/plane";
      "API_KEY_RATE_LIMIT" = "60/minute";
      "AWS_ACCESS_KEY_ID" = "access-key";
      "AWS_REGION" = "";
      "AWS_S3_BUCKET_NAME" = "uploads";
      "AWS_S3_ENDPOINT_URL" = "http://plane-minio:9000";
      "AWS_SECRET_ACCESS_KEY" = "secret-key";
      "BUCKET_NAME" = "uploads";
      "CORS_ALLOWED_ORIGINS" = "http://localhost:8081";
      "DATABASE_URL" = "postgresql://plane:plane@plane-db/plane";
      "DEBUG" = "0";
      "FILE_SIZE_LIMIT" = "5242880";
      "GUNICORN_WORKERS" = "1";
      "MINIO_ENDPOINT_SSL" = "0";
      "MINIO_ROOT_PASSWORD" = "secret-key";
      "MINIO_ROOT_USER" = "access-key";
      "NGINX_PORT" = "80";
      "PGDATA" = "/var/lib/postgresql/data";
      "PGDATABASE" = "plane";
      "PGHOST" = "plane-db";
      "POSTGRES_DB" = "plane";
      "POSTGRES_PASSWORD" = "plane";
      "POSTGRES_PORT" = "5432";
      "POSTGRES_USER" = "plane";
      "REDIS_HOST" = "plane-redis";
      "REDIS_PORT" = "6379";
      "REDIS_URL" = "redis://plane-redis:6379/";
      "SECRET_KEY" = "60gp0byfz2dvffa45cxl20p1scy9xbpf6d8c5y0geejgkyp1b5";
      "USE_MINIO" = "1";
      "WEB_URL" = "http://localhost:8081";
    };
    environmentFiles = [
      "/home/danielgm/Documents/Services/plane/plane-app/plane.env"
    ];
    volumes = [
      "plane_logs_worker:/code/plane/logs:rw"
    ];
    cmd = [ "./bin/docker-entrypoint-worker.sh" ];
    dependsOn = [
      "plane-api"
      "plane-plane-db"
      "plane-plane-mq"
      "plane-plane-redis"
    ];
    log-driver = "journald";
    extraOptions = [
      "--network-alias=worker"
      "--network=plane_default"
    ];
  };
  systemd.services."podman-plane-worker" = {
    serviceConfig = {
      Restart = lib.mkOverride 90 "on-failure";
      RestartSec = lib.mkOverride 90 0;
    };
    after = [
      "podman-network-plane_default.service"
      "podman-volume-plane_logs_worker.service"
    ];
    requires = [
      "podman-network-plane_default.service"
      "podman-volume-plane_logs_worker.service"
    ];
    partOf = [
      "podman-compose-plane-root.target"
    ];
    wantedBy = [
      "podman-compose-plane-root.target"
    ];
  };

  # Networks
  systemd.services."podman-network-plane_default" = {
    path = [ pkgs.podman ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStop = "podman network rm -f plane_default";
    };
    script = ''
      podman network inspect plane_default || podman network create plane_default
    '';
    partOf = [ "podman-compose-plane-root.target" ];
    wantedBy = [ "podman-compose-plane-root.target" ];
  };

  # Volumes
  systemd.services."podman-volume-plane_logs_api" = {
    path = [ pkgs.podman ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      podman volume inspect plane_logs_api || podman volume create plane_logs_api
    '';
    partOf = [ "podman-compose-plane-root.target" ];
    wantedBy = [ "podman-compose-plane-root.target" ];
  };
  systemd.services."podman-volume-plane_logs_beat-worker" = {
    path = [ pkgs.podman ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      podman volume inspect plane_logs_beat-worker || podman volume create plane_logs_beat-worker
    '';
    partOf = [ "podman-compose-plane-root.target" ];
    wantedBy = [ "podman-compose-plane-root.target" ];
  };
  systemd.services."podman-volume-plane_logs_migrator" = {
    path = [ pkgs.podman ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      podman volume inspect plane_logs_migrator || podman volume create plane_logs_migrator
    '';
    partOf = [ "podman-compose-plane-root.target" ];
    wantedBy = [ "podman-compose-plane-root.target" ];
  };
  systemd.services."podman-volume-plane_logs_worker" = {
    path = [ pkgs.podman ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      podman volume inspect plane_logs_worker || podman volume create plane_logs_worker
    '';
    partOf = [ "podman-compose-plane-root.target" ];
    wantedBy = [ "podman-compose-plane-root.target" ];
  };
  systemd.services."podman-volume-plane_pgdata" = {
    path = [ pkgs.podman ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      podman volume inspect plane_pgdata || podman volume create plane_pgdata
    '';
    partOf = [ "podman-compose-plane-root.target" ];
    wantedBy = [ "podman-compose-plane-root.target" ];
  };
  systemd.services."podman-volume-plane_rabbitmq_data" = {
    path = [ pkgs.podman ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      podman volume inspect plane_rabbitmq_data || podman volume create plane_rabbitmq_data
    '';
    partOf = [ "podman-compose-plane-root.target" ];
    wantedBy = [ "podman-compose-plane-root.target" ];
  };
  systemd.services."podman-volume-plane_redisdata" = {
    path = [ pkgs.podman ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      podman volume inspect plane_redisdata || podman volume create plane_redisdata
    '';
    partOf = [ "podman-compose-plane-root.target" ];
    wantedBy = [ "podman-compose-plane-root.target" ];
  };
  systemd.services."podman-volume-plane_uploads" = {
    path = [ pkgs.podman ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      podman volume inspect plane_uploads || podman volume create plane_uploads
    '';
    partOf = [ "podman-compose-plane-root.target" ];
    wantedBy = [ "podman-compose-plane-root.target" ];
  };

  # Root service
  # When started, this will automatically create all resources and start
  # the containers. When stopped, this will teardown all resources.
  systemd.targets."podman-compose-plane-root" = {
    unitConfig = {
      Description = "Root target generated by compose2nix.";
    };
    wantedBy = [ "multi-user.target" ];
  };
}
