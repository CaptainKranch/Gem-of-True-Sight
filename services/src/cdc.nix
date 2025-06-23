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
  virtualisation.oci-containers.containers."connect" = {
    image = "quay.io/debezium/connect:3.0";
    environment = {
      "BOOTSTRAP_SERVERS" = "kafka:9092";
      "CONFIG_STORAGE_TOPIC" = "my_connect_configs";
      "GROUP_ID" = "1";
      "OFFSET_STORAGE_TOPIC" = "my_connect_offsets";
      "STATUS_STORAGE_TOPIC" = "my_connect_statuses";
      "KAFKA_ADVERTISED_LISTENERS" = "PLAINTEXT://connect:8083";
      "KAFKA_LISTENERS" = "PLAINTEXT://0.0.0.0:8083";
    };
    ports = [
      "18083:8083/tcp"
    ];
    dependsOn = [
      "kafka"
      "mysql"
    ];
    log-driver = "journald";
    extraOptions = [
      "--network-alias=connect"
      "--network=cdc_default"
    ];
  };
  systemd.services."podman-connect" = {
    serviceConfig = {
      Restart = lib.mkOverride 90 "no";
    };
    after = [
      "podman-network-cdc_default.service"
    ];
    requires = [
      "podman-network-cdc_default.service"
    ];
    partOf = [
      "podman-compose-cdc-root.target"
    ];
    wantedBy = [
      "podman-compose-cdc-root.target"
    ];
  };
  virtualisation.oci-containers.containers."debezium-ui" = {
    image = "quay.io/debezium/debezium-ui:2.5";
    environment = {
      "KAFKA_CONNECT_URIS" = "http://connect:8083";
    };
    ports = [
      "28080:8080/tcp"
    ];
    dependsOn = [
      "connect"
    ];
    log-driver = "journald";
    extraOptions = [
      "--network-alias=debezium-ui"
      "--network=cdc_default"
    ];
  };
  systemd.services."podman-debezium-ui" = {
    serviceConfig = {
      Restart = lib.mkOverride 90 "no";
    };
    after = [
      "podman-network-cdc_default.service"
    ];
    requires = [
      "podman-network-cdc_default.service"
    ];
    partOf = [
      "podman-compose-cdc-root.target"
    ];
    wantedBy = [
      "podman-compose-cdc-root.target"
    ];
  };
  virtualisation.oci-containers.containers."kafka" = {
    image = "quay.io/debezium/kafka:3.0";
    environment = {
      "ZOOKEEPER_CONNECT" = "zookeeper:2181";
    };
    ports = [
      "9092:9092/tcp"
    ];
    dependsOn = [
      "zookeeper"
    ];
    log-driver = "journald";
    extraOptions = [
      "--network-alias=kafka"
      "--network=cdc_default"
    ];
  };
  systemd.services."podman-kafka" = {
    serviceConfig = {
      Restart = lib.mkOverride 90 "no";
    };
    after = [
      "podman-network-cdc_default.service"
    ];
    requires = [
      "podman-network-cdc_default.service"
    ];
    partOf = [
      "podman-compose-cdc-root.target"
    ];
    wantedBy = [
      "podman-compose-cdc-root.target"
    ];
  };
  virtualisation.oci-containers.containers."mysql" = {
    image = "quay.io/debezium/example-mysql:3.0";
    environment = {
      "MYSQL_PASSWORD" = "mysqlpw";
      "MYSQL_ROOT_PASSWORD" = "debezium";
      "MYSQL_USER" = "mysqluser";
    };
    ports = [
      "3306:3306/tcp"
    ];
    log-driver = "journald";
    extraOptions = [
      "--network-alias=mysql"
      "--network=cdc_default"
    ];
  };
  systemd.services."podman-mysql" = {
    serviceConfig = {
      Restart = lib.mkOverride 90 "no";
    };
    after = [
      "podman-network-cdc_default.service"
    ];
    requires = [
      "podman-network-cdc_default.service"
    ];
    partOf = [
      "podman-compose-cdc-root.target"
    ];
    wantedBy = [
      "podman-compose-cdc-root.target"
    ];
  };
  virtualisation.oci-containers.containers."zookeeper" = {
    image = "quay.io/debezium/zookeeper:3.0";
    ports = [
      "2181:2181/tcp"
      "2888:2888/tcp"
      "3888:3888/tcp"
    ];
    log-driver = "journald";
    extraOptions = [
      "--network-alias=zookeeper"
      "--network=cdc_default"
    ];
  };
  systemd.services."podman-zookeeper" = {
    serviceConfig = {
      Restart = lib.mkOverride 90 "no";
    };
    after = [
      "podman-network-cdc_default.service"
    ];
    requires = [
      "podman-network-cdc_default.service"
    ];
    partOf = [
      "podman-compose-cdc-root.target"
    ];
    wantedBy = [
      "podman-compose-cdc-root.target"
    ];
  };

  # Networks
  systemd.services."podman-network-cdc_default" = {
    path = [ pkgs.podman ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStop = "podman network rm -f cdc_default";
    };
    script = ''
      podman network inspect cdc_default || podman network create cdc_default
    '';
    partOf = [ "podman-compose-cdc-root.target" ];
    wantedBy = [ "podman-compose-cdc-root.target" ];
  };

  # Root service
  # When started, this will automatically create all resources and start
  # the containers. When stopped, this will teardown all resources.
  systemd.targets."podman-compose-cdc-root" = {
    unitConfig = {
      Description = "Root target generated by compose2nix.";
    };
    wantedBy = [ "multi-user.target" ];
  };
}
