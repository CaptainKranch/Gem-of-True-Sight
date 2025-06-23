# This is your system's configuration file.
# Use this to configure your system environment (it replaces /etc/nixos/configuration.nix)

{ inputs, lib, config, pkgs, ... }: {
  # You can import other NixOS modules here
  imports = [
    # If you want to use modules from other flakes (such as nixos-hardware):
    # inputs.hardware.nixosModules.common-cpu-amd
    # inputs.hardware.nixosModules.common-ssd

    # You can also split up your configuration and import pieces of it here:
    # Like services that you want to run in the background, like airflow, grafana, prometeus, etc.
    ../../services/medellin/default.nix
    #../../programs/terminal/nvim/default.nix

    # Agenix
    inputs.agenix.nixosModules.default

    # Import your generated (nixos-generate-config) hardware configuration
    ./hardware-configuration.nix
  ];

  nixpkgs = {
    # You can add overlays here
    overlays = [
      # If you want to use overlays exported from other flakes:
      # neovim-nightly-overlay.overlays.default
    ];
    # Configure your nixpkgs instance
    config = {
      allowUnfree = true;
    };
  };

  nix = {
    # This will add each flake input as a registry
    # To make nix3 commands consistent with your flake
    registry = lib.mapAttrs (_: value: { flake = value; }) inputs;

    # This will additionally add your inputs to the system's legacy channels
    # Making legacy nix commands consistent as well, awesome!
    nixPath = lib.mapAttrsToList (key: value: "${key}=${value.to.path}") config.nix.registry;

    settings = {
      # Enable flakes and new 'nix' command
      experimental-features = "nix-command flakes";
      # Deduplicate and optimize nix store
      auto-optimise-store = true;
    };
  };


# FIXME: Add the rest of your current configuration
  #Bootloader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  environment.systemPackages = with pkgs; [
    git
    vim
    home-manager
    yt-dlp
    xcaddy
    go
    cargo
    python3
    uv
  ];

  services.gnome.gnome-keyring.enable = true;
  services.gvfs.enable = true;
  services.tailscale.enable = true;

  # Reverse proxy
  systemd.services.caddy = {
    serviceConfig = {
      ExecStart = "/home/danielgm/Documents/Services/Caddy/caddy run --config /home/danielgm/Documents/Services/Caddy/Caddyfile";
#      User = "caddy";
#      Group = "caddy";
      AmbientCapabilities = "CAP_NET_BIND_SERVICE";
    };
  };
  users.users.caddy = {
    group = "caddy";
    createHome = true;
    home = "/var/lib/caddy";
    shell = "/bin/false";  # for non-login user
    isSystemUser = true;
  };
  users.groups.caddy = {};

  systemd.services.promtail = {
    description = "Promtail service for Loki";
    wantedBy = [ "multi-user.target" ];

    serviceConfig = {
      ExecStart = ''
        ${pkgs.grafana-loki}/bin/promtail --config.file ${../../services/src/promtail.yaml}
      '';
    };
  };

  services.loki = {
    enable = true;
    configuration = {
      server.http_listen_port = 3100;
      auth_enabled = false;

      ingester = {
        lifecycler = {
          address = "0.0.0.0";
          ring = {
            kvstore = {
              store = "inmemory";
            };
            replication_factor = 1;
          };
        };
        chunk_idle_period = "1h";
        max_chunk_age = "1h";
        chunk_target_size = 999999;
        chunk_retain_period = "30s";
  #      max_transfer_retries = 0;
      };

      schema_config = {
        configs = [{
          from = "2024-07-26";
          store = "boltdb-shipper";
          object_store = "filesystem";
          schema = "v11";  # Use a valid schema version
          index = {
            prefix = "index_";
            period = "24h";
          };
        }];
      };

      storage_config = {
        boltdb_shipper = {
          active_index_directory = "/var/lib/loki/boltdb-shipper-active";
          cache_location = "/var/lib/loki/boltdb-shipper-cache";
          cache_ttl = "24h";
  #        shared_store = "filesystem";
        };

        filesystem = {
          directory = "/var/lib/loki/chunks";
        };
      };

      limits_config = {
        reject_old_samples = true;
        reject_old_samples_max_age = "168h";
        allow_structured_metadata = false;  # Disable structured metadata
      };

  #    chunk_store_config = {
  #      max_look_back_period = "0s";
  #    };

      table_manager = {
        retention_deletes_enabled = false;
        retention_period = "0s";
      };

      compactor = {
        working_directory = "/var/lib/loki";
  #      shared_store = "filesystem";
        compactor_ring = {
          kvstore = {
            store = "inmemory";
          };
        };
      };
    };
  };

  # Services
  services = {
    grafana = {
      enable = true;
      settings.server = {
        http_port = 2342;
        http_addr = "0.0.0.0";
      };
    };
    prometheus = {
      enable = true;
      port = 9031;
      exporters = {
        node = {
          enable = true;
          enabledCollectors = [ "systemd" ];
          port = 9032;
        };
      };
      scrapeConfigs = [{
        job_name = "TeleAntioquia";
        static_configs = [{
          targets = [ "0.0.0.0:${toString config.services.prometheus.exporters.node.port}" ];
        }];
      }];
    };
    cockpit = {
      enable = true;
      port = 9090;
      settings = {
        WebService = {
          AllowUnencrypted = true;
        };
      };
    };
  };

  # Select internationalisation properties.
  time.timeZone = "America/Bogota";
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "es_CO.UTF-8";
    LC_IDENTIFICATION = "es_CO.UTF-8";
    LC_MEASUREMENT = "es_CO.UTF-8";
    LC_MONETARY = "es_CO.UTF-8";
    LC_NAME = "es_CO.UTF-8";
    LC_NUMERIC = "es_CO.UTF-8";
    LC_PAPER = "es_CO.UTF-8";
    LC_TELEPHONE = "es_CO.UTF-8";
    LC_TIME = "es_CO.UTF-8";
  };

  # TODO: Set your hostname
  networking.hostName = "medellin";
  networking.networkmanager.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ 2283 5432 6379 ];
  # networking.firewall.allowedUDPPorts = [ ];
  # Or disable the firewall altogether.
  networking.firewall.enable = false;

  # TODO: Configure your system-wide user settings (groups, etc), add more users as needed.
  users.users = {
    # FIXME: Replace with your username
    danielgm = {
      # TODO: You can set an initial password for your user.
      # If you do, you can skip setting a root password by passing '--no-root-passwd' to nixos-install.
      # Be sure to change it (using passwd) after rebooting!
      # initialPassword = "123";
      # shell = pkgs.nushell;
      isNormalUser = true;
      openssh.authorizedKeys.keys = [
        # TODO: Add your SSH public key(s) here, if you plan on using SSH to connect
      ];
      # TODO: Be sure to add any other groups you need (such as networkmanager, audio, docker, etc)
      extraGroups = [ "wheel" "docker" "networkmanager" "audio" "video" ];
    };
  };

  # This setups a SSH server. Very important if you're setting up a headless system.
  # Feel free to remove if you don't need it.
  services.openssh = {
    enable = true;
    # Forbid root login through SSH.
    settings = {
      PermitRootLogin = "no";
      PasswordAuthentication = true;
    };
    # Use keys only. Remove if you want to SSH using password (not recommended)
  };

  # Agenix configuration
  age.secrets.hoarder-openai-key = {
    file = ../../secrets/hoarder-openai-key.age;
    owner = "danielgm";
    group = "users";
  };
  
  age.secrets.minio-root-user = {
    file = ../../secrets/minio-root-user.age;
    owner = "danielgm";
    group = "users";
  };
  
  age.secrets.minio-root-password = {
    file = ../../secrets/minio-root-password.age;
    owner = "danielgm";
    group = "users";
  };
  
  age.secrets.postgres-password = {
    file = ../../secrets/postgres-password.age;
    owner = "danielgm";
    group = "users";
  };
  
  age.secrets.mysql-password = {
    file = ../../secrets/mysql-password.age;
    owner = "danielgm";
    group = "users";
  };
  
  age.secrets.mysql-root-password = {
    file = ../../secrets/mysql-root-password.age;
    owner = "danielgm";
    group = "users";
  };
  
  age.secrets.plex-claim = {
    file = ../../secrets/plex-claim.age;
    owner = "danielgm";
    group = "users";
  };

  # Create environment files from secrets
  systemd.services."hoarder-env-file" = {
    description = "Create hoarder environment file from secrets";
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      mkdir -p /run/secrets
      echo "OPENAI_API_KEY=$(cat ${config.age.secrets.hoarder-openai-key.path})" > /run/secrets/hoarder-env
      chmod 600 /run/secrets/hoarder-env
    '';
  };

  systemd.services."minio-env-file" = {
    description = "Create minio environment file from secrets";
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      mkdir -p /run/secrets
      echo "MINIO_ROOT_USER=$(cat ${config.age.secrets.minio-root-user.path})" > /run/secrets/minio-env
      echo "MINIO_ROOT_PASSWORD=$(cat ${config.age.secrets.minio-root-password.path})" >> /run/secrets/minio-env
      chmod 600 /run/secrets/minio-env
    '';
  };

  systemd.services."postgres-env-file" = {
    description = "Create postgres environment file from secrets";
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      mkdir -p /run/secrets
      echo "POSTGRES_PASSWORD=$(cat ${config.age.secrets.postgres-password.path})" > /run/secrets/postgres-env
      chmod 600 /run/secrets/postgres-env
    '';
  };

  systemd.services."mysql-env-file" = {
    description = "Create mysql environment file from secrets";
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      mkdir -p /run/secrets
      echo "MYSQL_PASSWORD=$(cat ${config.age.secrets.mysql-password.path})" > /run/secrets/mysql-env
      echo "MYSQL_ROOT_PASSWORD=$(cat ${config.age.secrets.mysql-root-password.path})" >> /run/secrets/mysql-env
      chmod 600 /run/secrets/mysql-env
    '';
  };

  systemd.services."plex-env-file" = {
    description = "Create plex environment file from secrets";
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      mkdir -p /run/secrets
      echo "PLEX_CLAIM=$(cat ${config.age.secrets.plex-claim.path})" > /run/secrets/plex-env
      chmod 600 /run/secrets/plex-env
    '';
  };

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "24.11";
}
