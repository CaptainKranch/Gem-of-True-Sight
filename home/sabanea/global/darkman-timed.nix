{ config, pkgs, lib, ... }:

let
  # Time configuration
  darkModeTime = "16:00"; # 4pm
  lightModeTime = "06:00"; # 6am (configurable)

  # Create wrapper scripts that trigger darkman mode changes
  switch-to-dark = pkgs.writeShellScriptBin "switch-to-dark" ''
    ${pkgs.darkman}/bin/darkman set dark
  '';

  switch-to-light = pkgs.writeShellScriptBin "switch-to-light" ''
    ${pkgs.darkman}/bin/darkman set light
  '';

in
{
  # Import the existing darkman configuration
  imports = [ ./darkman.nix ];

  # Override darkman settings to disable sunrise/sunset switching
  services.darkman.settings = lib.mkForce {
    # Keep the location for potential future use
    lat = 4.60971;
    lng = -74.08175;
    # Enable D-Bus and portal for manual control
    dbusserver = true;
    portal = true;
    # Disable automatic sunrise/sunset switching
    usegeoclue = false;
    # Set a very high sunrise/sunset offset to effectively disable auto-switching
    # This ensures darkman won't interfere with our timer-based switching
    sunrise-offset = 43200; # 12 hours offset
    sunset-offset = 43200;  # 12 hours offset
  };

  # Add the switching scripts to packages
  home.packages = with pkgs; [
    switch-to-dark
    switch-to-light
  ];

  # Create systemd timers for theme switching
  systemd.user.services = {
    "theme-switch-dark" = {
      Unit = {
        Description = "Switch to dark theme";
        After = [ "graphical-session.target" ];
      };
      Service = {
        Type = "oneshot";
        ExecStart = "${switch-to-dark}/bin/switch-to-dark";
      };
    };

    "theme-switch-light" = {
      Unit = {
        Description = "Switch to light theme";
        After = [ "graphical-session.target" ];
      };
      Service = {
        Type = "oneshot";
        ExecStart = "${switch-to-light}/bin/switch-to-light";
      };
    };
  };

  systemd.user.timers = {
    "theme-switch-dark" = {
      Unit = {
        Description = "Timer for dark theme switch at ${darkModeTime}";
      };
      Timer = {
        OnCalendar = darkModeTime;
        Persistent = true;
      };
      Install = {
        WantedBy = [ "timers.target" ];
      };
    };

    "theme-switch-light" = {
      Unit = {
        Description = "Timer for light theme switch at ${lightModeTime}";
      };
      Timer = {
        OnCalendar = lightModeTime;
        Persistent = true;
      };
      Install = {
        WantedBy = [ "timers.target" ];
      };
    };
  };

  # Create a startup service to set the correct theme based on current time
  systemd.user.services."theme-switch-startup" = {
    Unit = {
      Description = "Set theme based on current time at startup";
      After = [ "graphical-session.target" ];
    };
    Service = {
      Type = "oneshot";
      ExecStart = pkgs.writeShellScript "theme-startup" ''
        current_hour=$(date +%H)
        dark_hour=16  # 4pm
        light_hour=6  # 6am

        if [ $current_hour -ge $dark_hour ] || [ $current_hour -lt $light_hour ]; then
          ${switch-to-dark}/bin/switch-to-dark
        else
          ${switch-to-light}/bin/switch-to-light
        fi
      '';
    };
    Install = {
      WantedBy = [ "graphical-session.target" ];
    };
  };
}