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
    image = "quay.io/debezium/connect:3.1";
    environment = {
      "BOOTSTRAP_SERVERS" = "kafka:9092";
      "CONFIG_STORAGE_TOPIC" = "my_connect_configs";
      "GROUP_ID" = "1";
      "OFFSET_STORAGE_TOPIC" = "my_connect_offsets";
      "STATUS_STORAGE_TOPIC" = "my_connect_statuses";
    };
    ports = [
      "8083:8083/tcp"
    ];
    dependsOn = [
      "kafka"
    ];
    log-driver = "journald";
    extraOptions = [
      "--network-alias=connect"
      "--network=debizium_debezium-network"
    ];
  };
  systemd.services."podman-connect" = {
    serviceConfig = {
      Restart = lib.mkOverride 90 "no";
    };
    after = [
      "podman-network-debizium_debezium-network.service"
    ];
    requires = [
      "podman-network-debizium_debezium-network.service"
    ];
    partOf = [
      "podman-compose-debizium-root.target"
    ];
    wantedBy = [
      "podman-compose-debizium-root.target"
    ];
  };
  virtualisation.oci-containers.containers."debezium-ui" = {
    image = "quay.io/debezium/debezium-ui:2.5";
    environment = {
      "KAFKA_CONNECT_URIS" = "http://connect:8083";
    };
    ports = [
      "8087:8080/tcp"
    ];
    dependsOn = [
      "connect"
    ];
    log-driver = "journald";
    extraOptions = [
      "--network-alias=debezium-ui"
      "--network=debizium_debezium-network"
    ];
  };
  systemd.services."podman-debezium-ui" = {
    serviceConfig = {
      Restart = lib.mkOverride 90 "no";
    };
    after = [
      "podman-network-debizium_debezium-network.service"
    ];
    requires = [
      "podman-network-debizium_debezium-network.service"
    ];
    partOf = [
      "podman-compose-debizium-root.target"
    ];
    wantedBy = [
      "podman-compose-debizium-root.target"
    ];
  };
  virtualisation.oci-containers.containers."kafka" = {
    image = "quay.io/debezium/kafka:3.1";
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
      "--network=debizium_debezium-network"
    ];
  };
  systemd.services."podman-kafka" = {
    serviceConfig = {
      Restart = lib.mkOverride 90 "no";
    };
    after = [
      "podman-network-debizium_debezium-network.service"
    ];
    requires = [
      "podman-network-debizium_debezium-network.service"
    ];
    partOf = [
      "podman-compose-debizium-root.target"
    ];
    wantedBy = [
      "podman-compose-debizium-root.target"
    ];
  };
  virtualisation.oci-containers.containers."kafka-ui" = {
    image = "provectuslabs/kafka-ui:latest";
    environment = {
      "KAFKA_CLUSTERS_0_BOOTSTRAPSERVERS" = "kafka:9092";
      "KAFKA_CLUSTERS_0_KAFKACONNECT_0_ADDRESS" = "http://connect:8083";
      "KAFKA_CLUSTERS_0_KAFKACONNECT_0_NAME" = "debezium";
      "KAFKA_CLUSTERS_0_NAME" = "debezium-cluster";
      "KAFKA_CLUSTERS_0_SCHEMAREGISTRY" = "http://schema-registry:8081";
      "KAFKA_CLUSTERS_0_ZOOKEEPER" = "zookeeper:2181";
    };
    ports = [
      "8082:8080/tcp"
    ];
    dependsOn = [
      "connect"
      "kafka"
      "schema-registry"
      "zookeeper"
    ];
    log-driver = "journald";
    extraOptions = [
      "--network-alias=kafka-ui"
      "--network=debizium_debezium-network"
    ];
  };
  systemd.services."podman-kafka-ui" = {
    serviceConfig = {
      Restart = lib.mkOverride 90 "no";
    };
    after = [
      "podman-network-debizium_debezium-network.service"
    ];
    requires = [
      "podman-network-debizium_debezium-network.service"
    ];
    partOf = [
      "podman-compose-debizium-root.target"
    ];
    wantedBy = [
      "podman-compose-debizium-root.target"
    ];
  };
  virtualisation.oci-containers.containers."schema-registry" = {
    image = "confluentinc/cp-schema-registry:7.5.0";
    environment = {
      "SCHEMA_REGISTRY_HOST_NAME" = "schema-registry";
      "SCHEMA_REGISTRY_KAFKASTORE_BOOTSTRAP_SERVERS" = "kafka:9092";
      "SCHEMA_REGISTRY_LISTENERS" = "http://0.0.0.0:8081";
    };
    ports = [
      "8085:8081/tcp"
    ];
    dependsOn = [
      "kafka"
    ];
    log-driver = "journald";
    extraOptions = [
      "--network-alias=schema-registry"
      "--network=debizium_debezium-network"
    ];
  };
  systemd.services."podman-schema-registry" = {
    serviceConfig = {
      Restart = lib.mkOverride 90 "no";
    };
    after = [
      "podman-network-debizium_debezium-network.service"
    ];
    requires = [
      "podman-network-debizium_debezium-network.service"
    ];
    partOf = [
      "podman-compose-debizium-root.target"
    ];
    wantedBy = [
      "podman-compose-debizium-root.target"
    ];
  };
  virtualisation.oci-containers.containers."zookeeper" = {
    image = "quay.io/debezium/zookeeper:3.1";
    ports = [
      "2181:2181/tcp"
      "2888:2888/tcp"
      "3888:3888/tcp"
    ];
    log-driver = "journald";
    extraOptions = [
      "--network-alias=zookeeper"
      "--network=debizium_debezium-network"
    ];
  };
  systemd.services."podman-zookeeper" = {
    serviceConfig = {
      Restart = lib.mkOverride 90 "no";
    };
    after = [
      "podman-network-debizium_debezium-network.service"
    ];
    requires = [
      "podman-network-debizium_debezium-network.service"
    ];
    partOf = [
      "podman-compose-debizium-root.target"
    ];
    wantedBy = [
      "podman-compose-debizium-root.target"
    ];
  };

  # Networks
  systemd.services."podman-network-debizium_debezium-network" = {
    path = [ pkgs.podman ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStop = "podman network rm -f debizium_debezium-network";
    };
    script = ''
      podman network inspect debizium_debezium-network || podman network create debizium_debezium-network --driver=bridge
    '';
    partOf = [ "podman-compose-debizium-root.target" ];
    wantedBy = [ "podman-compose-debizium-root.target" ];
  };

  # Root service
  # When started, this will automatically create all resources and start
  # the containers. When stopped, this will teardown all resources.
  systemd.targets."podman-compose-debizium-root" = {
    unitConfig = {
      Description = "Root target generated by compose2nix.";
    };
    wantedBy = [ "multi-user.target" ];
  };
}
