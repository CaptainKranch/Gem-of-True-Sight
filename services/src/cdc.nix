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
      "CONFIG_STORAGE_REPLICATION_FACTOR" = "1";
      "CONFIG_STORAGE_TOPIC" = "debezium-configs";
      "CONNECT_CONNECTOR_CLIENT_CONFIG_OVERRIDE_POLICY" = "All";
      "CONNECT_LOG4J_LOGGERS" = "io.debezium=INFO,org.apache.kafka.connect=INFO";
      "GROUP_ID" = "debezium-cluster";
      "OFFSET_STORAGE_REPLICATION_FACTOR" = "1";
      "OFFSET_STORAGE_TOPIC" = "debezium-offsets";
      "STATUS_STORAGE_REPLICATION_FACTOR" = "1";
      "STATUS_STORAGE_TOPIC" = "debezium-status";
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
      "--network=debezium_debezium-network"
    ];
  };
  systemd.services."podman-connect" = {
    serviceConfig = {
      Restart = lib.mkOverride 90 "no";
    };
    after = [
      "podman-network-debezium_debezium-network.service"
    ];
    requires = [
      "podman-network-debezium_debezium-network.service"
    ];
    partOf = [
      "podman-compose-debezium-root.target"
    ];
    wantedBy = [
      "podman-compose-debezium-root.target"
    ];
  };
  virtualisation.oci-containers.containers."debezium-ui" = {
    image = "quay.io/debezium/debezium-ui:2.5";
    environment = {
      "KAFKA_CONNECT_URIS" = "http://connect:8083";
    };
    ports = [
      "8080:8080/tcp"
    ];
    dependsOn = [
      "connect"
    ];
    log-driver = "journald";
    extraOptions = [
      "--network-alias=debezium-ui"
      "--network=debezium_debezium-network"
    ];
  };
  systemd.services."podman-debezium-ui" = {
    serviceConfig = {
      Restart = lib.mkOverride 90 "no";
    };
    after = [
      "podman-network-debezium_debezium-network.service"
    ];
    requires = [
      "podman-network-debezium_debezium-network.service"
    ];
    partOf = [
      "podman-compose-debezium-root.target"
    ];
    wantedBy = [
      "podman-compose-debezium-root.target"
    ];
  };
  virtualisation.oci-containers.containers."kafka" = {
    image = "quay.io/debezium/kafka:3.1";
    environment = {
      "CLUSTER_ID" = "MkU3OEVBNTcwNTJENDM2Qk";
      "KAFKA_ADVERTISED_LISTENERS" = "PLAINTEXT://kafka:9092";
      "KAFKA_CONTROLLER_LISTENER_NAMES" = "CONTROLLER";
      "KAFKA_CONTROLLER_QUORUM_VOTERS" = "1@kafka:9093";
      "KAFKA_ENABLE_KRAFT" = "yes";
      "KAFKA_INTER_BROKER_LISTENER_NAME" = "PLAINTEXT";
      "KAFKA_LISTENERS" = "PLAINTEXT://0.0.0.0:9092,CONTROLLER://0.0.0.0:9093";
      "KAFKA_LISTENER_SECURITY_PROTOCOL_MAP" = "CONTROLLER:PLAINTEXT,PLAINTEXT:PLAINTEXT";
      "KAFKA_LOG_DIRS" = "/kafka/logs";
      "KAFKA_NODE_ID" = "1";
      "KAFKA_OFFSETS_TOPIC_REPLICATION_FACTOR" = "1";
      "KAFKA_PROCESS_ROLES" = "controller,broker";
      "KAFKA_TRANSACTION_STATE_LOG_MIN_ISR" = "1";
      "KAFKA_TRANSACTION_STATE_LOG_REPLICATION_FACTOR" = "1";
    };
    volumes = [
      "debezium_kafka-data:/kafka/logs:rw"
    ];
    ports = [
      "9092:9092/tcp"
    ];
    log-driver = "journald";
    extraOptions = [
      "--network-alias=kafka"
      "--network=debezium_debezium-network"
    ];
  };
  systemd.services."podman-kafka" = {
    serviceConfig = {
      Restart = lib.mkOverride 90 "no";
    };
    after = [
      "podman-network-debezium_debezium-network.service"
      "podman-volume-debezium_kafka-data.service"
    ];
    requires = [
      "podman-network-debezium_debezium-network.service"
      "podman-volume-debezium_kafka-data.service"
    ];
    partOf = [
      "podman-compose-debezium-root.target"
    ];
    wantedBy = [
      "podman-compose-debezium-root.target"
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
    };
    ports = [
      "8082:8080/tcp"
    ];
    dependsOn = [
      "connect"
      "kafka"
      "schema-registry"
    ];
    log-driver = "journald";
    extraOptions = [
      "--network-alias=kafka-ui"
      "--network=debezium_debezium-network"
    ];
  };
  systemd.services."podman-kafka-ui" = {
    serviceConfig = {
      Restart = lib.mkOverride 90 "no";
    };
    after = [
      "podman-network-debezium_debezium-network.service"
    ];
    requires = [
      "podman-network-debezium_debezium-network.service"
    ];
    partOf = [
      "podman-compose-debezium-root.target"
    ];
    wantedBy = [
      "podman-compose-debezium-root.target"
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
      "--network=debezium_debezium-network"
    ];
  };
  systemd.services."podman-schema-registry" = {
    serviceConfig = {
      Restart = lib.mkOverride 90 "no";
    };
    after = [
      "podman-network-debezium_debezium-network.service"
    ];
    requires = [
      "podman-network-debezium_debezium-network.service"
    ];
    partOf = [
      "podman-compose-debezium-root.target"
    ];
    wantedBy = [
      "podman-compose-debezium-root.target"
    ];
  };

  # Networks
  systemd.services."podman-network-debezium_debezium-network" = {
    path = [ pkgs.podman ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStop = "podman network rm -f debezium_debezium-network";
    };
    script = ''
      podman network inspect debezium_debezium-network || podman network create debezium_debezium-network --driver=bridge
    '';
    partOf = [ "podman-compose-debezium-root.target" ];
    wantedBy = [ "podman-compose-debezium-root.target" ];
  };

  # Volumes
  systemd.services."podman-volume-debezium_kafka-data" = {
    path = [ pkgs.podman ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      podman volume inspect debezium_kafka-data || podman volume create debezium_kafka-data
    '';
    partOf = [ "podman-compose-debezium-root.target" ];
    wantedBy = [ "podman-compose-debezium-root.target" ];
  };

  # Root service
  # When started, this will automatically create all resources and start
  # the containers. When stopped, this will teardown all resources.
  systemd.targets."podman-compose-debezium-root" = {
    unitConfig = {
      Description = "Root target generated by compose2nix.";
    };
    wantedBy = [ "multi-user.target" ];
  };
}
