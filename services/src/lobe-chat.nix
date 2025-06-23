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
  virtualisation.oci-containers.containers."lobe-casdoor" = {
    image = "casbin/casdoor:v1.843.0";
    environment = {
      "APP_URL" = "http://localhost:3210";
      "AUTH_CASDOOR_ID" = "a387a4892ee19b1a2249";
      "AUTH_CASDOOR_ISSUER" = "http://localhost:8000";
      "AUTH_CASDOOR_SECRET" = "dbf205949d704de81b0b5b3603174e23fbecc354";
      "AUTH_URL" = "http://localhost:3210/api/auth";
      "CASDOOR_PORT" = "8000";
      "LOBE_DB_NAME" = "lobechat";
      "LOBE_PORT" = "3210";
      "MINIO_LOBE_BUCKET" = "lobe";
      "MINIO_PORT" = "9000";
      "MINIO_ROOT_PASSWORD" = "YOUR_MINIO_PASSWORD";
      "MINIO_ROOT_USER" = "admin";
      "POSTGRES_PASSWORD" = "uWNZugjBqixf8dxC";
      "RUNNING_IN_DOCKER" = "true";
      "S3_ENDPOINT" = "http://localhost:9000";
      "S3_PUBLIC_DOMAIN" = "http://localhost:9000";
      "dataSourceName" = "user=postgres password=uWNZugjBqixf8dxC host=postgresql port=5432 sslmode=disable dbname=casdoor";
      "driverName" = "postgres";
      "httpport" = "8000";
      "origin" = "http://localhost:8000";
      "runmode" = "dev";
    };
    volumes = [
      "/home/danielgm/Documents/Services/lobe-chat/init_data.json:/init_data.json:rw"
    ];
    dependsOn = [
      "lobe-network"
      "lobe-postgres"
    ];
    log-driver = "journald";
    extraOptions = [
      "--entrypoint=[\"/bin/sh\", \"-c\", \"./server --createDatabase=true\"]"
      "--network=container:lobe-network"
    ];
  };
  systemd.services."podman-lobe-casdoor" = {
    serviceConfig = {
      Restart = lib.mkOverride 90 "no";
    };
    partOf = [
      "podman-compose-ai-chat-root.target"
    ];
    wantedBy = [
      "podman-compose-ai-chat-root.target"
    ];
  };
  virtualisation.oci-containers.containers."lobe-chat" = {
    image = "lobehub/lobe-chat-database";
    environment = {
      "APP_URL" = "http://localhost:3210";
      "AUTH_CASDOOR_ID" = "a387a4892ee19b1a2249";
      "AUTH_CASDOOR_ISSUER" = "http://localhost:8000";
      "AUTH_CASDOOR_SECRET" = "dbf205949d704de81b0b5b3603174e23fbecc354";
      "AUTH_URL" = "http://localhost:3210/api/auth";
      "CASDOOR_PORT" = "8000";
      "DATABASE_URL" = "postgresql://postgres:uWNZugjBqixf8dxC@postgresql:5432/lobechat";
      "KEY_VAULTS_SECRET" = "Kix2wcUONd4CX51E/ZPAd36BqM4wzJgKjPtz2sGztqQ=";
      "LLM_VISION_IMAGE_USE_BASE64" = "1";
      "LOBE_DB_NAME" = "lobechat";
      "LOBE_PORT" = "3210";
      "MINIO_LOBE_BUCKET" = "lobe";
      "MINIO_PORT" = "9000";
      "MINIO_ROOT_PASSWORD" = "YOUR_MINIO_PASSWORD";
      "MINIO_ROOT_USER" = "admin";
      "NEXT_AUTH_SECRET" = "NX2kaPE923dt6BL2U8e9oSre5RfoT7hg";
      "NEXT_AUTH_SSO_PROVIDERS" = "casdoor";
      "POSTGRES_PASSWORD" = "uWNZugjBqixf8dxC";
      "S3_ACCESS_KEY" = "admin";
      "S3_ACCESS_KEY_ID" = "admin";
      "S3_BUCKET" = "lobe";
      "S3_ENABLE_PATH_STYLE" = "1";
      "S3_ENDPOINT" = "http://localhost:9000";
      "S3_PUBLIC_DOMAIN" = "http://localhost:9000";
      "S3_SECRET_ACCESS_KEY" = "YOUR_MINIO_PASSWORD";
      "S3_SET_ACL" = "0";
      "SEARXNG_URL" = "http://searxng:8080";
      "origin" = "http://localhost:8000";
    };
    dependsOn = [
      "lobe-casdoor"
      "lobe-minio"
      "lobe-network"
      "lobe-postgres"
    ];
    log-driver = "journald";
    extraOptions = [
      "--entrypoint=[\"/bin/sh\", \"-c\", \"
    /bin/node /app/startServer.js &
    LOBE_PID=$!
    sleep 3
    if [ $(wget --timeout=5 --spider --server-response http://localhost:8000/.well-known/openid-configuration 2>&1 | grep -c 'HTTP/1.1 200 OK') -eq 0 ]; then
      echo '⚠️Warining: Unable to fetch OIDC configuration from Casdoor'
      echo 'Request URL: http://localhost:8000/.well-known/openid-configuration'
      echo 'Read more at: https://lobehub.com/docs/self-hosting/server-database/docker-compose#necessary-configuration'
      echo ''
      echo '⚠️注意：无法从 Casdoor 获取 OIDC 配置'
      echo '请求 URL: http://localhost:8000/.well-known/openid-configuration'
      echo '了解更多：https://lobehub.com/zh/docs/self-hosting/server-database/docker-compose#necessary-configuration'
      echo ''
    else
      if ! wget -O - --timeout=5 http://localhost:8000/.well-known/openid-configuration 2>&1 | grep 'issuer' | grep http://localhost:8000; then
        printf '❌Error: The Auth issuer is conflict, Issuer in OIDC configuration is: %s' $(wget -O - --timeout=5 http://localhost:8000/.well-known/openid-configuration 2>&1 | grep -E 'issuer.*' | awk -F '\"' '{print $4}')
        echo ' , but the issuer in .env file is: http://localhost:8000 '
        echo 'Request URL: http://localhost:8000/.well-known/openid-configuration'
        echo 'Read more at: https://lobehub.com/docs/self-hosting/server-database/docker-compose#necessary-configuration'
        echo ''
        printf '❌错误：Auth 的 issuer 冲突，OIDC 配置中的 issuer 是：%s' $(wget -O - --timeout=5 http://localhost:8000/.well-known/openid-configuration 2>&1 | grep -E 'issuer.*' | awk -F '\"' '{print $4}')
        echo ' , 但 .env 文件中的 issuer 是：http://localhost:8000 '
        echo '请求 URL: http://localhost:8000/.well-known/openid-configuration'
        echo '了解更多：https://lobehub.com/zh/docs/self-hosting/server-database/docker-compose#necessary-configuration'
        echo ''
      fi
    fi
    if [ $(wget --timeout=5 --spider --server-response http://localhost:9000/minio/health/live 2>&1 | grep -c 'HTTP/1.1 200 OK') -eq 0 ]; then
      echo '⚠️Warining: Unable to fetch MinIO health status'
      echo 'Request URL: http://localhost:9000/minio/health/live'
      echo 'Read more at: https://lobehub.com/docs/self-hosting/server-database/docker-compose#necessary-configuration'
      echo ''
      echo '⚠️注意：无法获取 MinIO 健康状态'
      echo '请求 URL: http://localhost:9000/minio/health/live'
      echo '了解更多：https://lobehub.com/zh/docs/self-hosting/server-database/docker-compose#necessary-configuration'
      echo ''
    fi
    wait
  \"]"
      "--network=container:lobe-network"
    ];
  };
  systemd.services."podman-lobe-chat" = {
    serviceConfig = {
      Restart = lib.mkOverride 90 "always";
    };
    partOf = [
      "podman-compose-ai-chat-root.target"
    ];
    wantedBy = [
      "podman-compose-ai-chat-root.target"
    ];
  };
  virtualisation.oci-containers.containers."lobe-minio" = {
    image = "minio/minio";
    environment = {
      "APP_URL" = "http://localhost:3210";
      "AUTH_CASDOOR_ID" = "a387a4892ee19b1a2249";
      "AUTH_CASDOOR_ISSUER" = "http://localhost:8000";
      "AUTH_CASDOOR_SECRET" = "dbf205949d704de81b0b5b3603174e23fbecc354";
      "AUTH_URL" = "http://localhost:3210/api/auth";
      "CASDOOR_PORT" = "8000";
      "LOBE_DB_NAME" = "lobechat";
      "LOBE_PORT" = "3210";
      "MINIO_API_CORS_ALLOW_ORIGIN" = "*";
      "MINIO_LOBE_BUCKET" = "lobe";
      "MINIO_PORT" = "9000";
      "MINIO_ROOT_PASSWORD" = "YOUR_MINIO_PASSWORD";
      "MINIO_ROOT_USER" = "admin";
      "POSTGRES_PASSWORD" = "uWNZugjBqixf8dxC";
      "S3_ENDPOINT" = "http://localhost:9000";
      "S3_PUBLIC_DOMAIN" = "http://localhost:9000";
      "origin" = "http://localhost:8000";
    };
    volumes = [
      "/home/danielgm/Documents/Services/lobe-chat/s3_data:/etc/minio/data:rw"
    ];
    dependsOn = [
      "lobe-network"
    ];
    log-driver = "journald";
    cmd = [
      ''

        minio server /etc/minio/data --address ':9000' --console-address ':9001' &
        MINIO_PID=$!
        while ! curl -s http://localhost:9000/minio/health/live; do
          echo 'Waiting for MinIO to start...'
          sleep 1
        done
        sleep 5
        # Ensure mc is available or use podman exec - Use full path if necessary
        # Assuming mc is in the minio/minio image path or added via pkgs
        mc alias set myminio http://localhost:9000 admin YOUR_MINIO_PASSWORD
        echo 'Creating bucket lobe'
        mc mb myminio/lobe
        wait $MINIO_PID # Wait specifically for the minio server PID
      ''
    ];
    extraOptions = [
      "--network=container:lobe-network"
    ];
  };
  systemd.services."podman-lobe-minio" = {
    serviceConfig = {
      Restart = lib.mkOverride 90 "always";
    };
    partOf = [
      "podman-compose-ai-chat-root.target"
    ];
    wantedBy = [
      "podman-compose-ai-chat-root.target"
    ];
  };
  virtualisation.oci-containers.containers."lobe-network" = {
    image = "alpine";
    ports = [
      "9000:9000/tcp"
      "9001:9001/tcp"
      "8000:8000/tcp"
      "3210:3210/tcp"
    ];
    cmd = [ "tail" "-f" "/dev/null" ];
    log-driver = "journald";
    extraOptions = [
      "--network-alias=network-service"
      "--network=ai-chat_lobe-network"
    ];
  };
  systemd.services."podman-lobe-network" = {
    serviceConfig = {
      Restart = lib.mkOverride 90 "always";
    };
    after = [
      "podman-network-ai-chat_lobe-network.service"
    ];
    requires = [
      "podman-network-ai-chat_lobe-network.service"
    ];
    partOf = [
      "podman-compose-ai-chat-root.target"
    ];
    wantedBy = [
      "podman-compose-ai-chat-root.target"
    ];
  };
  virtualisation.oci-containers.containers."lobe-postgres" = {
    image = "pgvector/pgvector:pg17";
    environment = {
      "POSTGRES_DB" = "lobechat";
      "POSTGRES_PASSWORD" = "uWNZugjBqixf8dxC";
    };
    volumes = [
      "/home/danielgm/Documents/Services/lobe-chat/data:/var/lib/postgresql/data:rw"
    ];
    ports = [
      "5432:5432/tcp"
    ];
    log-driver = "journald";
    extraOptions = [
      "--health-cmd=pg_isready -U postgres"
      "--health-interval=5s"
      "--health-retries=5"
      "--health-timeout=5s"
      "--network-alias=postgresql"
      "--network=ai-chat_lobe-network"
    ];
  };
  systemd.services."podman-lobe-postgres" = {
    serviceConfig = {
      Restart = lib.mkOverride 90 "always";
    };
    after = [
      "podman-network-ai-chat_lobe-network.service"
    ];
    requires = [
      "podman-network-ai-chat_lobe-network.service"
    ];
    partOf = [
      "podman-compose-ai-chat-root.target"
    ];
    wantedBy = [
      "podman-compose-ai-chat-root.target"
    ];
  };
  virtualisation.oci-containers.containers."lobe-searxng" = {
    image = "searxng/searxng";
    environment = {
      "APP_URL" = "http://localhost:3210";
      "AUTH_CASDOOR_ID" = "a387a4892ee19b1a2249";
      "AUTH_CASDOOR_ISSUER" = "http://localhost:8000";
      "AUTH_CASDOOR_SECRET" = "dbf205949d704de81b0b5b3603174e23fbecc354";
      "AUTH_URL" = "http://localhost:3210/api/auth";
      "CASDOOR_PORT" = "8000";
      "LOBE_DB_NAME" = "lobechat";
      "LOBE_PORT" = "3210";
      "MINIO_LOBE_BUCKET" = "lobe";
      "MINIO_PORT" = "9000";
      "MINIO_ROOT_PASSWORD" = "YOUR_MINIO_PASSWORD";
      "MINIO_ROOT_USER" = "admin";
      "POSTGRES_PASSWORD" = "uWNZugjBqixf8dxC";
      "S3_ENDPOINT" = "http://localhost:9000";
      "S3_PUBLIC_DOMAIN" = "http://localhost:9000";
      "SEARXNG_SETTINGS_FILE" = "/etc/searxng/settings.yml";
      "origin" = "http://localhost:8000";
    };
    volumes = [
      "/home/danielgm/Documents/Services/lobe-chat/searxng-settings.yml:/etc/searxng/settings.yml:rw"
    ];
    log-driver = "journald";
    extraOptions = [
      "--network-alias=searxng"
      "--network=ai-chat_lobe-network"
    ];
  };
  systemd.services."podman-lobe-searxng" = {
    serviceConfig = {
      Restart = lib.mkOverride 90 "always";
    };
    after = [
      "podman-network-ai-chat_lobe-network.service"
    ];
    requires = [
      "podman-network-ai-chat_lobe-network.service"
    ];
    partOf = [
      "podman-compose-ai-chat-root.target"
    ];
    wantedBy = [
      "podman-compose-ai-chat-root.target"
    ];
  };

  # Networks
  systemd.services."podman-network-ai-chat_lobe-network" = {
    path = [ pkgs.podman ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStop = "podman network rm -f ai-chat_lobe-network";
    };
    script = ''
      podman network inspect ai-chat_lobe-network || podman network create ai-chat_lobe-network --driver=bridge
    '';
    partOf = [ "podman-compose-ai-chat-root.target" ];
    wantedBy = [ "podman-compose-ai-chat-root.target" ];
  };

  # Root service
  # When started, this will automatically create all resources and start
  # the containers. When stopped, this will teardown all resources.
  systemd.targets."podman-compose-ai-chat-root" = {
    unitConfig = {
      Description = "Root target generated by compose2nix.";
    };
    wantedBy = [ "multi-user.target" ];
  };
}
