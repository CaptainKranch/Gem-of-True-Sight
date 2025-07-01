{ config, pkgs, lib, ... }:

let
  # Time configuration - easily adjustable
  darkModeTime = "16:00"; # 4pm
  lightModeTime = "06:00"; # 6am

  # Import all the theme switching scripts from darkman.nix
  dark-mode-notify = pkgs.writeShellScriptBin "dark-mode-notify" ''
    ${pkgs.libnotify}/bin/notify-send "Theme Change" "Switched to dark mode" -i weather-clear-night
    ${pkgs.procps}/bin/pkill -USR1 nvim || true
  '';

  light-mode-notify = pkgs.writeShellScriptBin "light-mode-notify" ''
    ${pkgs.libnotify}/bin/notify-send "Theme Change" "Switched to light mode" -i weather-clear
    ${pkgs.procps}/bin/pkill -USR1 nvim || true
  '';

  # Master switching scripts that call all individual theme scripts
  switch-to-dark = pkgs.writeShellScriptBin "switch-to-dark" ''
    # GTK Theme
    ${pkgs.dconf}/bin/dconf write /org/gnome/desktop/interface/gtk-theme "'adw-gtk3-dark'"
    ${pkgs.dconf}/bin/dconf write /org/gnome/desktop/interface/color-scheme "'prefer-dark'"
    
    # Icon Theme
    ${pkgs.dconf}/bin/dconf write /org/gnome/desktop/interface/icon-theme "'Papirus-Dark'"
    
    # Kitty Terminal
    ${pkgs.kitty}/bin/kitty +kitten themes --reload-in=all Tokyo Night || true
    
    # Qt Theme
    mkdir -p "$HOME/.config/qt5ct"
    cat > "$HOME/.config/qt5ct/qt5ct.conf" << EOF
    [Appearance]
    style=Adwaita-Dark
    color_scheme_path=/usr/share/qt5ct/colors/darker.conf
    custom_palette=false
    icon_theme=Papirus-Dark
    EOF
    
    mkdir -p "$HOME/.config/qt6ct"
    cp "$HOME/.config/qt5ct/qt5ct.conf" "$HOME/.config/qt6ct/qt6ct.conf"
    
    # Electron apps preference
    mkdir -p "$HOME/.config/theme"
    echo "dark" > "$HOME/.config/theme/current"
    
    # Notify
    ${dark-mode-notify}/bin/dark-mode-notify
  '';

  switch-to-light = pkgs.writeShellScriptBin "switch-to-light" ''
    # GTK Theme
    ${pkgs.dconf}/bin/dconf write /org/gnome/desktop/interface/gtk-theme "'adw-gtk3'"
    ${pkgs.dconf}/bin/dconf write /org/gnome/desktop/interface/color-scheme "'prefer-light'"
    
    # Icon Theme
    ${pkgs.dconf}/bin/dconf write /org/gnome/desktop/interface/icon-theme "'Papirus-Light'"
    
    # Kitty Terminal
    ${pkgs.kitty}/bin/kitty +kitten themes --reload-in=all Tokyo Night Day || true
    
    # Qt Theme
    mkdir -p "$HOME/.config/qt5ct"
    cat > "$HOME/.config/qt5ct/qt5ct.conf" << EOF
    [Appearance]
    style=Adwaita
    color_scheme_path=/usr/share/qt5ct/colors/airy.conf
    custom_palette=false
    icon_theme=Papirus-Light
    EOF
    
    mkdir -p "$HOME/.config/qt6ct"
    cp "$HOME/.config/qt5ct/qt5ct.conf" "$HOME/.config/qt6ct/qt6ct.conf"
    
    # Electron apps preference
    mkdir -p "$HOME/.config/theme"
    echo "light" > "$HOME/.config/theme/current"
    
    # Notify
    ${light-mode-notify}/bin/light-mode-notify
  '';

  # Manual toggle script
  toggle-theme = pkgs.writeShellScriptBin "toggle-theme" ''
    THEME_FILE="$HOME/.config/theme/current"
    mkdir -p "$(dirname "$THEME_FILE")"
    
    if [ ! -f "$THEME_FILE" ] || [ "$(cat "$THEME_FILE")" = "light" ]; then
      ${switch-to-dark}/bin/switch-to-dark
    else
      ${switch-to-light}/bin/switch-to-light
    fi
  '';

in
{
  home.packages = with pkgs; [
    switch-to-dark
    switch-to-light
    toggle-theme
    dark-mode-notify
    light-mode-notify
  ];

  # Systemd services and timers
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

    "theme-switch-startup" = {
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
}