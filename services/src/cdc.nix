{ pkgs, lib, config, ... }:

{
  # Runtime
  virtualisation.podman = {
    enable = true;
    autoPrune.enable = true;
    dockerCompat = true;
  };

  virtualisation.oci-containers.backend = "podman";

  # First, we need to generate a cluster ID for KRaft
  # You can generate one with: podman run --rm quay.io/debezium/kafka:3.1 kafka-storage.sh random-uuid
  # For this example, I'll use a pre-generated one
  
  # Containers
  virtualisation.oci-containers.containers."kafka-controller-1" = {
    image = "quay.io/debezium/kafka:3.1";
    environment = {
      "KAFKA_NODE_ID" = "1";
      "KAFKA_PROCESS_ROLES" = "controller";
      "KAFKA_CONTROLLER_QUORUM_VOTERS" = "1@kafka-controller-1:9093,2@kafka-controller-2:9093,3@kafka-controller-3:9093";
      "KAFKA_LISTENERS" = "CONTROLLER://0.0.0.0:9093";
      "KAFKA_CONTROLLER_LISTENER_NAMES" = "CONTROLLER";
      "CLUSTER_ID" = "MkU3OEVBNTcwNTJENDM2Qk";
    };
    extraOptions = [
      "--network-alias=kafka-controller-1"
      "--network=debezium_debezium-network"
    ];
  };

  virtualisation.oci-containers.containers."kafka-controller-2" = {
    image = "quay.io/debezium/kafka:3.1";
    environment = {
      "KAFKA_NODE_ID" = "2";
      "KAFKA_PROCESS_ROLES" = "controller";
      "KAFKA_CONTROLLER_QUORUM_VOTERS" = "1@kafka-controller-1:9093,2@kafka-controller-2:9093,3@kafka-controller-3:9093";
      "KAFKA_LISTENERS" = "CONTROLLER://0.0.0.0:9093";
      "KAFKA_CONTROLLER_LISTENER_NAMES" = "CONTROLLER";
      "CLUSTER_ID" = "MkU3OEVBNTcwNTJENDM2Qk";
    };
    extraOptions = [
      "--network-alias=kafka-controller-2"
      "--network=debezium_debezium-network"
    ];
  };

  virtualisation.oci-containers.containers."kafka-controller-3" = {
    image = "quay.io/debezium/kafka:3.1";
    environment = {
      "KAFKA_NODE_ID" = "3";
      "KAFKA_PROCESS_ROLES" = "controller";
      "KAFKA_CONTROLLER_QUORUM_VOTERS" = "1@kafka-controller-1:9093,2@kafka-controller-2:9093,3@kafka-controller-3:9093";
      "KAFKA_LISTENERS" = "CONTROLLER://0.0.0.0:9093";
      "KAFKA_CONTROLLER_LISTENER_NAMES" = "CONTROLLER";
      "CLUSTER_ID" = "MkU3OEVBNTcwNTJENDM2Qk";
    };
    extraOptions = [
      "--network-alias=kafka-controller-3"
      "--network=debezium_debezium-network"
    ];
  };

  virtualisation.oci-containers.containers."kafka-broker-1" = {
    image = "quay.io/debezium/kafka:3.1";
    ports = [
      "9092:9092/tcp"
    ];
    environment = {
      "KAFKA_NODE_ID" = "4";
      "KAFKA_PROCESS_ROLES" = "broker";
      "KAFKA_LISTENERS" = "PLAINTEXT://0.0.0.0:9092,INTERNAL://0.0.0.0:19092";
      "KAFKA_ADVERTISED_LISTENERS" = "PLAINTEXT://localhost:9092,INTERNAL://kafka-broker-1:19092";
      "KAFKA_INTER_BROKER_LISTENER_NAME" = "INTERNAL";
      "KAFKA_CONTROLLER_QUORUM_VOTERS" = "1@kafka-controller-1:9093,2@kafka-controller-2:9093,3@kafka-controller-3:9093";
      "KAFKA_CONTROLLER_LISTENER_NAMES" = "CONTROLLER";
      "CLUSTER_ID" = "MkU3OEVBNTcwNTJENDM2Qk";
      "KAFKA_OFFSETS_TOPIC_REPLICATION_FACTOR" = "3";
      "KAFKA_TRANSACTION_STATE_LOG_REPLICATION_FACTOR" = "3";
      "KAFKA_TRANSACTION_STATE_LOG_MIN_ISR" = "2";
    };
    dependsOn = [
      "kafka-controller-1"
      "kafka-controller-2"
      "kafka-controller-3"
    ];
    extraOptions = [
      "--network-alias=kafka-broker-1"
      "--network=debezium_debezium-network"
    ];
  };

  virtualisation.oci-containers.containers."kafka-broker-2" = {
    image = "quay.io/debezium/kafka:3.1";
    ports = [
      "9093:9092/tcp"
    ];
    environment = {
      "KAFKA_NODE_ID" = "5";
      "KAFKA_PROCESS_ROLES" = "broker";
      "KAFKA_LISTENERS" = "PLAINTEXT://0.0.0.0:9092,INTERNAL://0.0.0.0:19092";
      "KAFKA_ADVERTISED_LISTENERS" = "PLAINTEXT://localhost:9093,INTERNAL://kafka-broker-2:19092";
      "KAFKA_INTER_BROKER_LISTENER_NAME" = "INTERNAL";
      "KAFKA_CONTROLLER_QUORUM_VOTERS" = "1@kafka-controller-1:9093,2@kafka-controller-2:9093,3@kafka-controller-3:9093";
      "KAFKA_CONTROLLER_LISTENER_NAMES" = "CONTROLLER";
      "CLUSTER_ID" = "MkU3OEVBNTcwNTJENDM2Qk";
      "KAFKA_OFFSETS_TOPIC_REPLICATION_FACTOR" = "3";
      "KAFKA_TRANSACTION_STATE_LOG_REPLICATION_FACTOR" = "3";
      "KAFKA_TRANSACTION_STATE_LOG_MIN_ISR" = "2";
    };
    dependsOn = [
      "kafka-controller-1"
      "kafka-controller-2"
      "kafka-controller-3"
    ];
    extraOptions = [
      "--network-alias=kafka-broker-2"
      "--network=debezium_debezium-network"
    ];
  };

  virtualisation.oci-containers.containers."kafka-broker-3" = {
    image = "quay.io/debezium/kafka:3.1";
    ports = [
      "9094:9092/tcp"
    ];
    environment = {
      "KAFKA_NODE_ID" = "6";
      "KAFKA_PROCESS_ROLES" = "broker";
      "KAFKA_LISTENERS" = "PLAINTEXT://0.0.0.0:9092,INTERNAL://0.0.0.0:19092";
      "KAFKA_ADVERTISED_LISTENERS" = "PLAINTEXT://localhost:9094,INTERNAL://kafka-broker-3:19092";
      "KAFKA_INTER_BROKER_LISTENER_NAME" = "INTERNAL";
      "KAFKA_CONTROLLER_QUORUM_VOTERS" = "1@kafka-controller-1:9093,2@kafka-controller-2:9093,3@kafka-controller-3:9093";
      "KAFKA_CONTROLLER_LISTENER_NAMES" = "CONTROLLER";
      "CLUSTER_ID" = "MkU3OEVBNTcwNTJENDM2Qk";
      "KAFKA_OFFSETS_TOPIC_REPLICATION_FACTOR" = "3";
      "KAFKA_TRANSACTION_STATE_LOG_REPLICATION_FACTOR" = "3";
      "KAFKA_TRANSACTION_STATE_LOG_MIN_ISR" = "2";
    };
    dependsOn = [
      "kafka-controller-1"
      "kafka-controller-2"
      "kafka-controller-3"
    ];
    extraOptions = [
      "--network-alias=kafka-broker-3"
      "--network=debezium_debezium-network"
    ];
  };

  virtualisation.oci-containers.containers."debezium-connect" = {
    image = "quay.io/debezium/connect:3.1";
    ports = [
      "8083:8083/tcp"
    ];
    environment = {
      "BOOTSTRAP_SERVERS" = "kafka-broker-1:19092,kafka-broker-2:19092,kafka-broker-3:19092";
      "GROUP_ID" = "debezium-cluster";
      "CONFIG_STORAGE_TOPIC" = "debezium-configs";
      "OFFSET_STORAGE_TOPIC" = "debezium-offsets";
      "STATUS_STORAGE_TOPIC" = "debezium-status";
      "CONFIG_STORAGE_REPLICATION_FACTOR" = "3";
      "OFFSET_STORAGE_REPLICATION_FACTOR" = "3";
      "STATUS_STORAGE_REPLICATION_FACTOR" = "3";
      "CONNECT_CONNECTOR_CLIENT_CONFIG_OVERRIDE_POLICY" = "All";
      "CONNECT_LOG4J_LOGGERS" = "io.debezium=DEBUG,org.apache.kafka.connect=INFO";
      "KAFKA_JVM_PERFORMANCE_OPTS" = "-XX:+UseG1GC -XX:MaxGCPauseMillis=20 -XX:InitiatingHeapOccupancyPercent=35 -XX:+ExplicitGCInvokesConcurrent";
      "KAFKA_HEAP_OPTS" = "-Xms2G -Xmx2G";
    };
    dependsOn = [
      "kafka-broker-1"
      "kafka-broker-2"
      "kafka-broker-3"
    ];
    extraOptions = [
      "--network-alias=debezium-connect"
      "--network=debezium_debezium-network"
    ];
  };

  virtualisation.oci-containers.containers."debezium-ui" = {
    image = "quay.io/debezium/debezium-ui:2.5";
    ports = [
      "8080:8080/tcp"
    ];
    environment = {
      "KAFKA_CONNECT_URIS" = "http://debezium-connect:8083";
    };
    dependsOn = [
      "debezium-connect"
    ];
    extraOptions = [
      "--network-alias=debezium-ui"
      "--network=debezium_debezium-network"
    ];
  };

  # Schema Registry - Changed port to avoid conflict
  virtualisation.oci-containers.containers."schema-registry" = {
    image = "confluentinc/cp-schema-registry:7.5.0";
    ports = [
      "8085:8081/tcp"  # Changed from 8081 to 8085 to avoid conflict
    ];
    environment = {
      "SCHEMA_REGISTRY_HOST_NAME" = "schema-registry";
      "SCHEMA_REGISTRY_KAFKASTORE_BOOTSTRAP_SERVERS" = "kafka-broker-1:19092,kafka-broker-2:19092,kafka-broker-3:19092";
      "SCHEMA_REGISTRY_LISTENERS" = "http://0.0.0.0:8081";
    };
    dependsOn = [
      "kafka-broker-1"
      "kafka-broker-2"
      "kafka-broker-3"
    ];
    extraOptions = [
      "--network-alias=schema-registry"
      "--network=debezium_debezium-network"
    ];
  };

  # Kafka UI
  virtualisation.oci-containers.containers."kafka-ui" = {
    image = "provectuslabs/kafka-ui:latest";
    ports = [
      "8082:8080/tcp"
    ];
    environment = {
      "KAFKA_CLUSTERS_0_NAME" = "debezium-cluster";
      "KAFKA_CLUSTERS_0_BOOTSTRAPSERVERS" = "kafka-broker-1:19092,kafka-broker-2:19092,kafka-broker-3:19092";
      "KAFKA_CLUSTERS_0_SCHEMAREGISTRY" = "http://schema-registry:8081";
      "KAFKA_CLUSTERS_0_KAFKACONNECT_0_NAME" = "debezium";
      "KAFKA_CLUSTERS_0_KAFKACONNECT_0_ADDRESS" = "http://debezium-connect:8083";
    };
    dependsOn = [
      "kafka-broker-1"
      "kafka-broker-2"
      "kafka-broker-3"
      "schema-registry"
      "debezium-connect"
    ];
    extraOptions = [
      "--network-alias=kafka-ui"
      "--network=debezium_debezium-network"
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
      podman network inspect debezium_debezium-network || podman network create debezium_debezium-network
    '';
    partOf = [ "podman-compose-debezium-root.target" ];
    wantedBy = [ "podman-compose-debezium-root.target" ];
  };

  # Root service
  systemd.targets."podman-compose-debezium-root" = {
    unitConfig = {
      Description = "Root target generated by compose2nix for Debezium.";
    };
    wantedBy = [ "multi-user.target" ];
  };

  # Add systemd service dependencies
  systemd.services = {
    "podman-kafka-controller-1" = {
      serviceConfig = {
        Restart = lib.mkOverride 90 "on-failure";
        RestartSec = "30s";
      };
      after = [ "podman-network-debezium_debezium-network.service" ];
      requires = [ "podman-network-debezium_debezium-network.service" ];
      partOf = [ "podman-compose-debezium-root.target" ];
      wantedBy = [ "podman-compose-debezium-root.target" ];
    };
    
    "podman-kafka-controller-2" = {
      serviceConfig = {
        Restart = lib.mkOverride 90 "on-failure";
        RestartSec = "30s";
      };
      after = [ "podman-network-debezium_debezium-network.service" ];
      requires = [ "podman-network-debezium_debezium-network.service" ];
      partOf = [ "podman-compose-debezium-root.target" ];
      wantedBy = [ "podman-compose-debezium-root.target" ];
    };
    
    "podman-kafka-controller-3" = {
      serviceConfig = {
        Restart = lib.mkOverride 90 "on-failure";
        RestartSec = "30s";
      };
      after = [ "podman-network-debezium_debezium-network.service" ];
      requires = [ "podman-network-debezium_debezium-network.service" ];
      partOf = [ "podman-compose-debezium-root.target" ];
      wantedBy = [ "podman-compose-debezium-root.target" ];
    };
    
    "podman-kafka-broker-1" = {
      serviceConfig = {
        Restart = lib.mkOverride 90 "on-failure";
        RestartSec = "30s";
      };
      after = [ "podman-network-debezium_debezium-network.service" ];
      requires = [ "podman-network-debezium_debezium-network.service" ];
      partOf = [ "podman-compose-debezium-root.target" ];
      wantedBy = [ "podman-compose-debezium-root.target" ];
    };
    
    "podman-kafka-broker-2" = {
      serviceConfig = {
        Restart = lib.mkOverride 90 "on-failure";
        RestartSec = "30s";
      };
      after = [ "podman-network-debezium_debezium-network.service" ];
      requires = [ "podman-network-debezium_debezium-network.service" ];
      partOf = [ "podman-compose-debezium-root.target" ];
      wantedBy = [ "podman-compose-debezium-root.target" ];
    };
    
    "podman-kafka-broker-3" = {
      serviceConfig = {
        Restart = lib.mkOverride 90 "on-failure";
        RestartSec = "30s";
      };
      after = [ "podman-network-debezium_debezium-network.service" ];
      requires = [ "podman-network-debezium_debezium-network.service" ];
      partOf = [ "podman-compose-debezium-root.target" ];
      wantedBy = [ "podman-compose-debezium-root.target" ];
    };
    
    "podman-debezium-connect" = {
      serviceConfig = {
        Restart = lib.mkOverride 90 "on-failure";
        RestartSec = "30s";
      };
      after = [ "podman-network-debezium_debezium-network.service" ];
      requires = [ "podman-network-debezium_debezium-network.service" ];
      partOf = [ "podman-compose-debezium-root.target" ];
      wantedBy = [ "podman-compose-debezium-root.target" ];
    };
    
    "podman-debezium-ui" = {
      serviceConfig = {
        Restart = lib.mkOverride 90 "on-failure";
        RestartSec = "30s";
      };
      after = [ "podman-network-debezium_debezium-network.service" ];
      requires = [ "podman-network-debezium_debezium-network.service" ];
      partOf = [ "podman-compose-debezium-root.target" ];
      wantedBy = [ "podman-compose-debezium-root.target" ];
    };
    
    "podman-schema-registry" = {
      serviceConfig = {
        Restart = lib.mkOverride 90 "on-failure";
        RestartSec = "30s";
      };
      after = [ "podman-network-debezium_debezium-network.service" ];
      requires = [ "podman-network-debezium_debezium-network.service" ];
      partOf = [ "podman-compose-debezium-root.target" ];
      wantedBy = [ "podman-compose-debezium-root.target" ];
    };
    
    "podman-kafka-ui" = {
      serviceConfig = {
        Restart = lib.mkOverride 90 "on-failure";
        RestartSec = "30s";
      };
      after = [ "podman-network-debezium_debezium-network.service" ];
      requires = [ "podman-network-debezium_debezium-network.service" ];
      partOf = [ "podman-compose-debezium-root.target" ];
      wantedBy = [ "podman-compose-debezium-root.target" ];
    };
  };
}
