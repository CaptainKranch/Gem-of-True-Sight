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
    #../../services/default.nix
    

    # Import your generated (nixos-generate-config) hardware configuration
    ./hardware-configuration.nix
  ];
  
  nixpkgs = {
    # You can add overlays here
    overlays = [
      # If you want to use overlays exported from other flakes:
      # neovim-nightly-overlay.overlays.default
      (final: prev: {
        dwm = prev.dwm.overrideAttrs (old: { 
          src = /home/danielgm/.config/nix/Gem-of-true-sight/modules/dwm;
          }
        );
      })
      (final: prev: {
        dmenu = prev.dmenu.overrideAttrs (old: { 
          src = /home/danielgm/.config/nix/Gem-of-true-sight/modules/dmenu;
          }
        );
      })
#      (final: prev: {
#        opencode = prev.opencode.overrideAttrs (oldAttrs: rec {
#          version = "0.1.172";
#          src = prev.fetchFromGitHub {
#            owner = "sst";
#            repo = "opencode";
#            rev = "v${version}";
#            hash = "sha256-7z1vlhPqaLd6tQ0N/fCCTBR1HZ6z6mvUZFzw082Y2dU=";
#          };
#        });
#      })
      (final: prev: {
        duckdb = prev.duckdb.overrideAttrs (oldAttrs: rec {
          version = "1.3.1";
          src = prev.fetchFromGitHub {
            owner = "duckdb";
            repo = "duckdb";
            rev = "v${version}";
            # Hash obtained using: nix-prefetch-url --unpack https://github.com/duckdb/duckdb/archive/v1.3.1.tar.gz
            hash = "sha256-32wEbYF3immUkwGVeLFNncQ5pRpA4ujbaCNwBUcmMNA=";
          };
        });
      })
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
  boot.kernelParams = [ "i915.enable_psr=0" ];

  environment.systemPackages = with pkgs; [ 
    (import ../../scripts/screenshotsel.nix { inherit pkgs; })
    (import ../../scripts/wallpaper.nix { inherit pkgs; })
    #(import ../../scripts/liveWall.nix { inherit pkgs; })
    (import ../../scripts/lock-screen.nix { inherit pkgs; })
    (import ../../scripts/kitty-theme.nix { inherit pkgs; })
    git
    picom
    dmenu
    home-manager
    pavucontrol
    podman
    podman-compose
    podman-desktop
    awscli2
    azure-cli
    go
    cargo
    ffmpeg
    mpv
    tlp
    python312
    uv
    dbeaver-bin
    networkmanager-openvpn
    networkmanagerapplet
    lxappearance
    duckdb
    inputs.zen-browser.packages.${pkgs.system}.default
    xorg.libX11
    xorg.libX11.dev
    xorg.libxcb
    xorg.libXft
    xorg.libXinerama
    xorg.xinit
    xorg.xinput
    gcc
    stdenv.cc.cc.lib
  ];
  
  # Steam
  programs.steam = {
    enable = true;
  };
  
  services = {
    xserver = {
      enable = true;
      windowManager.dwm.enable = true;
      videoDrivers = [ "intel" ];
      config = ''
        Section "Device"
          Identifier  "Intel Graphics"
          Driver      "intel"
          Option      "TearFree" "true"
        EndSection
      '';
    };
    pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
    };
    tlp = {
      enable = true;
      settings = {
        START_CHARGE_THRESH_BAT0 = 40;
        STOP_CHARGE_THRESH_BAT0  = 80;
      };
    };
    # Varios
    displayManager.autoLogin.enable = true;
    displayManager.autoLogin.user = "danielgm";
    pulseaudio.enable = false;
    blueman.enable = true;
    gnome.gnome-keyring.enable = true;
    gvfs.enable = true;
    tailscale.enable = true;
    ratbagd.enable = true;
  };
  
  #Audio
  #sound.enable = false;
  security.rtkit.enable = true;

  # Bluethooth
  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;
  hardware.logitech.wireless.enable = true;

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
  networking.hostName = "sabanea";
  networking.networkmanager.enable = true;
  #networking.nameservers = [ "1.1.1.1" "1.0.0.1" "8.8.8.8" ];

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
      #initialPassword = "123";
      #shell = pkgs.nushell;
      isNormalUser = true;
      openssh.authorizedKeys.keys = [
        # TODO: Add your SSH public key(s) here, if you plan on using SSH to connect
      ];
      # TODO: Be sure to add any other groups you need (such as networkmanager, audio, docker, etc)
      extraGroups = [ "wheel" "networkmanager" "audio" "video" ];
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

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "24.05";
}
