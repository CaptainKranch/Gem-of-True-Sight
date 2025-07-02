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
  virtualisation.oci-containers.containers."debezium-connect" = {
    image = "quay.io/debezium/connect:3.1";
    environment = {
      "BOOTSTRAP_SERVERS" = "kafka-broker-1:19092,kafka-broker-2:19092,kafka-broker-3:19092";
      "CONFIG_STORAGE_REPLICATION_FACTOR" = "3";
      "CONFIG_STORAGE_TOPIC" = "debezium-configs";
      "CONNECT_CONNECTOR_CLIENT_CONFIG_OVERRIDE_POLICY" = "All";
      "CONNECT_LOG4J_LOGGERS" = "io.debezium=DEBUG,org.apache.kafka.connect=INFO";
      "GROUP_ID" = "debezium-cluster";
      "KAFKA_HEAP_OPTS" = "-Xms2G -Xmx2G";
      "KAFKA_JVM_PERFORMANCE_OPTS" = "-XX:+UseG1GC -XX:MaxGCPauseMillis=20 -XX:InitiatingHeapOccupancyPercent=35 -XX:+ExplicitGCInvokesConcurrent";
      "OFFSET_STORAGE_REPLICATION_FACTOR" = "3";
      "OFFSET_STORAGE_TOPIC" = "debezium-offsets";
      "STATUS_STORAGE_REPLICATION_FACTOR" = "3";
      "STATUS_STORAGE_TOPIC" = "debezium-status";
    };
    ports = [
      "8083:8083/tcp"
    ];
    dependsOn = [
      "kafka-broker-1"
      "kafka-broker-2"
      "kafka-broker-3"
    ];
    log-driver = "journald";
    extraOptions = [
      "--network-alias=connect"
      "--network=debizium_debezium-network"
    ];
  };
  systemd.services."podman-debezium-connect" = {
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
      "8080:8080/tcp"
    ];
    dependsOn = [
      "debezium-connect"
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
  virtualisation.oci-containers.containers."kafka-broker-1" = {
    image = "quay.io/debezium/kafka:3.1";
    environment = {
      "CLUSTER_ID" = "MkU3OTk5NTk2ODI5Mzg2Nz";
      "KAFKA_ADVERTISED_LISTENERS" = "PLAINTEXT://localhost:9092,INTERNAL://kafka-broker-1:19092";
      "KAFKA_CONTROLLER_LISTENER_NAMES" = "CONTROLLER";
      "KAFKA_CONTROLLER_QUORUM_VOTERS" = "1@kafka-controller-1:9093,2@kafka-controller-2:9093,3@kafka-controller-3:9093";
      "KAFKA_INTER_BROKER_LISTENER_NAME" = "INTERNAL";
      "KAFKA_LISTENERS" = "PLAINTEXT://0.0.0.0:9092,INTERNAL://0.0.0.0:19092";
      "KAFKA_NODE_ID" = "4";
      "KAFKA_OFFSETS_TOPIC_REPLICATION_FACTOR" = "3";
      "KAFKA_PROCESS_ROLES" = "broker";
      "KAFKA_TRANSACTION_STATE_LOG_MIN_ISR" = "2";
      "KAFKA_TRANSACTION_STATE_LOG_REPLICATION_FACTOR" = "3";
    };
    ports = [
      "9092:9092/tcp"
    ];
    dependsOn = [
      "kafka-controller-1"
      "kafka-controller-2"
      "kafka-controller-3"
    ];
    log-driver = "journald";
    extraOptions = [
      "--network-alias=kafka-broker-1"
      "--network=debizium_debezium-network"
    ];
  };
  systemd.services."podman-kafka-broker-1" = {
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
  virtualisation.oci-containers.containers."kafka-broker-2" = {
    image = "quay.io/debezium/kafka:3.1";
    environment = {
      "CLUSTER_ID" = "MkU3OTk5NTk2ODI5Mzg2Nz";
      "KAFKA_ADVERTISED_LISTENERS" = "PLAINTEXT://localhost:9093,INTERNAL://kafka-broker-2:19092";
      "KAFKA_CONTROLLER_LISTENER_NAMES" = "CONTROLLER";
      "KAFKA_CONTROLLER_QUORUM_VOTERS" = "1@kafka-controller-1:9093,2@kafka-controller-2:9093,3@kafka-controller-3:9093";
      "KAFKA_INTER_BROKER_LISTENER_NAME" = "INTERNAL";
      "KAFKA_LISTENERS" = "PLAINTEXT://0.0.0.0:9092,INTERNAL://0.0.0.0:19092";
      "KAFKA_NODE_ID" = "5";
      "KAFKA_OFFSETS_TOPIC_REPLICATION_FACTOR" = "3";
      "KAFKA_PROCESS_ROLES" = "broker";
      "KAFKA_TRANSACTION_STATE_LOG_MIN_ISR" = "2";
      "KAFKA_TRANSACTION_STATE_LOG_REPLICATION_FACTOR" = "3";
    };
    ports = [
      "9093:9092/tcp"
    ];
    dependsOn = [
      "kafka-controller-1"
      "kafka-controller-2"
      "kafka-controller-3"
    ];
    log-driver = "journald";
    extraOptions = [
      "--network-alias=kafka-broker-2"
      "--network=debizium_debezium-network"
    ];
  };
  systemd.services."podman-kafka-broker-2" = {
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
  virtualisation.oci-containers.containers."kafka-broker-3" = {
    image = "quay.io/debezium/kafka:3.1";
    environment = {
      "CLUSTER_ID" = "MkU3OTk5NTk2ODI5Mzg2Nz";
      "KAFKA_ADVERTISED_LISTENERS" = "PLAINTEXT://localhost:9094,INTERNAL://kafka-broker-3:19092";
      "KAFKA_CONTROLLER_LISTENER_NAMES" = "CONTROLLER";
      "KAFKA_CONTROLLER_QUORUM_VOTERS" = "1@kafka-controller-1:9093,2@kafka-controller-2:9093,3@kafka-controller-3:9093";
      "KAFKA_INTER_BROKER_LISTENER_NAME" = "INTERNAL";
      "KAFKA_LISTENERS" = "PLAINTEXT://0.0.0.0:9092,INTERNAL://0.0.0.0:19092";
      "KAFKA_NODE_ID" = "6";
      "KAFKA_OFFSETS_TOPIC_REPLICATION_FACTOR" = "3";
      "KAFKA_PROCESS_ROLES" = "broker";
      "KAFKA_TRANSACTION_STATE_LOG_MIN_ISR" = "2";
      "KAFKA_TRANSACTION_STATE_LOG_REPLICATION_FACTOR" = "3";
    };
    ports = [
      "9094:9092/tcp"
    ];
    dependsOn = [
      "kafka-controller-1"
      "kafka-controller-2"
      "kafka-controller-3"
    ];
    log-driver = "journald";
    extraOptions = [
      "--network-alias=kafka-broker-3"
      "--network=debizium_debezium-network"
    ];
  };
  systemd.services."podman-kafka-broker-3" = {
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
  virtualisation.oci-containers.containers."kafka-controller-1" = {
    image = "quay.io/debezium/kafka:3.1";
    environment = {
      "CLUSTER_ID" = "MkU3OTk5NTk2ODI5Mzg2Nz";
      "KAFKA_CONTROLLER_LISTENER_NAMES" = "CONTROLLER";
      "KAFKA_CONTROLLER_QUORUM_VOTERS" = "1@kafka-controller-1:9093,2@kafka-controller-2:9093,3@kafka-controller-3:9093";
      "KAFKA_LISTENERS" = "CONTROLLER://0.0.0.0:9093";
      "KAFKA_NODE_ID" = "1";
      "KAFKA_PROCESS_ROLES" = "controller";
    };
    log-driver = "journald";
    extraOptions = [
      "--network-alias=kafka-controller-1"
      "--network=debizium_debezium-network"
    ];
  };
  systemd.services."podman-kafka-controller-1" = {
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
  virtualisation.oci-containers.containers."kafka-controller-2" = {
    image = "quay.io/debezium/kafka:3.1";
    environment = {
      "CLUSTER_ID" = "MkU3OTk5NTk2ODI5Mzg2Nz";
      "KAFKA_CONTROLLER_LISTENER_NAMES" = "CONTROLLER";
      "KAFKA_CONTROLLER_QUORUM_VOTERS" = "1@kafka-controller-1:9093,2@kafka-controller-2:9093,3@kafka-controller-3:9093";
      "KAFKA_LISTENERS" = "CONTROLLER://0.0.0.0:9093";
      "KAFKA_NODE_ID" = "2";
      "KAFKA_PROCESS_ROLES" = "controller";
    };
    log-driver = "journald";
    extraOptions = [
      "--network-alias=kafka-controller-2"
      "--network=debizium_debezium-network"
    ];
  };
  systemd.services."podman-kafka-controller-2" = {
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
  virtualisation.oci-containers.containers."kafka-controller-3" = {
    image = "quay.io/debezium/kafka:3.1";
    environment = {
      "CLUSTER_ID" = "MkU3OTk5NTk2ODI5Mzg2Nz";
      "KAFKA_CONTROLLER_LISTENER_NAMES" = "CONTROLLER";
      "KAFKA_CONTROLLER_QUORUM_VOTERS" = "1@kafka-controller-1:9093,2@kafka-controller-2:9093,3@kafka-controller-3:9093";
      "KAFKA_LISTENERS" = "CONTROLLER://0.0.0.0:9093";
      "KAFKA_NODE_ID" = "3";
      "KAFKA_PROCESS_ROLES" = "controller";
    };
    log-driver = "journald";
    extraOptions = [
      "--network-alias=kafka-controller-3"
      "--network=debizium_debezium-network"
    ];
  };
  systemd.services."podman-kafka-controller-3" = {
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
      "KAFKA_CLUSTERS_0_BOOTSTRAPSERVERS" = "kafka-broker-1:19092,kafka-broker-2:19092,kafka-broker-3:19092";
      "KAFKA_CLUSTERS_0_KAFKACONNECT_0_ADDRESS" = "http://connect:8083";
      "KAFKA_CLUSTERS_0_KAFKACONNECT_0_NAME" = "debezium";
      "KAFKA_CLUSTERS_0_NAME" = "debezium-cluster";
      "KAFKA_CLUSTERS_0_SCHEMAREGISTRY" = "http://schema-registry:8081";
    };
    ports = [
      "8082:8080/tcp"
    ];
    dependsOn = [
      "debezium-connect"
      "kafka-broker-1"
      "kafka-broker-2"
      "kafka-broker-3"
      "schema-registry"
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
      "SCHEMA_REGISTRY_KAFKASTORE_BOOTSTRAP_SERVERS" = "kafka-broker-1:19092,kafka-broker-2:19092,kafka-broker-3:19092";
      "SCHEMA_REGISTRY_LISTENERS" = "http://0.0.0.0:8081";
    };
    ports = [
      "8081:8081/tcp"
    ];
    dependsOn = [
      "kafka-broker-1"
      "kafka-broker-2"
      "kafka-broker-3"
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
