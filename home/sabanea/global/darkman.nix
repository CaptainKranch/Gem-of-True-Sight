{ config, pkgs, ... }:

let
  dark-mode-notify = pkgs.writeShellScriptBin "dark-mode-notify" ''
    ${pkgs.libnotify}/bin/notify-send "Theme Change" "Switched to dark mode" -i weather-clear-night
    ${pkgs.procps}/bin/pkill -USR1 nvim || true
  '';

  light-mode-notify = pkgs.writeShellScriptBin "light-mode-notify" ''
    ${pkgs.libnotify}/bin/notify-send "Theme Change" "Switched to light mode" -i weather-clear
    ${pkgs.procps}/bin/pkill -USR1 nvim || true
  '';

  gtk-dark = pkgs.writeShellScriptBin "gtk-dark" ''
    ${pkgs.dconf}/bin/dconf write /org/gnome/desktop/interface/gtk-theme "'adw-gtk3-dark'"
    ${pkgs.dconf}/bin/dconf write /org/gnome/desktop/interface/color-scheme "'prefer-dark'"
  '';

  gtk-light = pkgs.writeShellScriptBin "gtk-light" ''
    ${pkgs.dconf}/bin/dconf write /org/gnome/desktop/interface/gtk-theme "'adw-gtk3'"
    ${pkgs.dconf}/bin/dconf write /org/gnome/desktop/interface/color-scheme "'prefer-light'"
  '';

  icon-dark = pkgs.writeShellScriptBin "icon-dark" ''
    ${pkgs.dconf}/bin/dconf write /org/gnome/desktop/interface/icon-theme "'Papirus-Dark'"
  '';

  icon-light = pkgs.writeShellScriptBin "icon-light" ''
    ${pkgs.dconf}/bin/dconf write /org/gnome/desktop/interface/icon-theme "'Papirus-Light'"
  '';

  kitty-dark = pkgs.writeShellScriptBin "kitty-dark" ''
    ${pkgs.kitty}/bin/kitty +kitten themes --reload-in=all Tokyo Night
  '';

  kitty-light = pkgs.writeShellScriptBin "kitty-light" ''
    ${pkgs.kitty}/bin/kitty +kitten themes --reload-in=all Tokyo Night Day
  '';

  slack-dark = pkgs.writeShellScriptBin "slack-dark" ''
    # Slack stores preferences in a JSON file
    CONFIG_PATH="$HOME/.config/Slack/storage/root-state.json"
    if [ -f "$CONFIG_PATH" ]; then
      ${pkgs.jq}/bin/jq '.settings.userTheme = "dark" | .settings.slackDefaults.userTheme = "dark" | .settings.userChoices.userTheme = "dark" | .settings.systemThemeSyncEnabled = false' "$CONFIG_PATH" > "$CONFIG_PATH.tmp" && ${pkgs.coreutils}/bin/mv "$CONFIG_PATH.tmp" "$CONFIG_PATH"
    fi
  '';

  slack-light = pkgs.writeShellScriptBin "slack-light" ''
    # Slack stores preferences in a JSON file
    CONFIG_PATH="$HOME/.config/Slack/storage/root-state.json"
    if [ -f "$CONFIG_PATH" ]; then
      ${pkgs.jq}/bin/jq '.settings.userTheme = "light" | .settings.slackDefaults.userTheme = "light" | .settings.userChoices.userTheme = "light" | .settings.systemThemeSyncEnabled = false' "$CONFIG_PATH" > "$CONFIG_PATH.tmp" && ${pkgs.coreutils}/bin/mv "$CONFIG_PATH.tmp" "$CONFIG_PATH"
    fi
  '';

  dbeaver-dark = pkgs.writeShellScriptBin "dbeaver-dark" ''
    # DBeaver theme is stored in workspace preferences
    PREFS_PATH="$HOME/.local/share/DBeaverData/workspace6/.metadata/.plugins/org.eclipse.core.runtime/.settings/org.eclipse.e4.ui.css.swt.theme.prefs"
    if [ -f "$PREFS_PATH" ]; then
      ${pkgs.gnused}/bin/sed -i 's/themeid=.*/themeid=org.eclipse.e4.ui.css.theme.e4_dark/g' "$PREFS_PATH"
    fi
  '';

  dbeaver-light = pkgs.writeShellScriptBin "dbeaver-light" ''
    # DBeaver theme is stored in workspace preferences
    PREFS_PATH="$HOME/.local/share/DBeaverData/workspace6/.metadata/.plugins/org.eclipse.core.runtime/.settings/org.eclipse.e4.ui.css.swt.theme.prefs"
    if [ -f "$PREFS_PATH" ]; then
      ${pkgs.gnused}/bin/sed -i 's/themeid=.*/themeid=org.eclipse.e4.ui.css.theme.e4_default/g' "$PREFS_PATH"
    fi
  '';

  qt-dark = pkgs.writeShellScriptBin "qt-dark" ''
    # Set Qt5 theme configuration
    ${pkgs.coreutils}/bin/mkdir -p "$HOME/.config/qt5ct"
    ${pkgs.coreutils}/bin/cat > "$HOME/.config/qt5ct/qt5ct.conf" << EOF
    [Appearance]
    style=Adwaita-Dark
    color_scheme_path=/usr/share/qt5ct/colors/darker.conf
    custom_palette=false
    icon_theme=Papirus-Dark
    EOF
    
    # Set Qt6 configuration
    ${pkgs.coreutils}/bin/mkdir -p "$HOME/.config/qt6ct"
    ${pkgs.coreutils}/bin/cp "$HOME/.config/qt5ct/qt5ct.conf" "$HOME/.config/qt6ct/qt6ct.conf"
  '';

  qt-light = pkgs.writeShellScriptBin "qt-light" ''
    # Set Qt5 theme configuration
    ${pkgs.coreutils}/bin/mkdir -p "$HOME/.config/qt5ct"
    ${pkgs.coreutils}/bin/cat > "$HOME/.config/qt5ct/qt5ct.conf" << EOF
    [Appearance]
    style=Adwaita
    color_scheme_path=/usr/share/qt5ct/colors/airy.conf
    custom_palette=false
    icon_theme=Papirus-Light
    EOF
    
    # Set Qt6 configuration
    ${pkgs.coreutils}/bin/mkdir -p "$HOME/.config/qt6ct"
    ${pkgs.coreutils}/bin/cp "$HOME/.config/qt5ct/qt5ct.conf" "$HOME/.config/qt6ct/qt6ct.conf"
  '';

  electron-dark = pkgs.writeShellScriptBin "electron-dark" ''
    # Create a config file that Electron apps can read
    ${pkgs.coreutils}/bin/mkdir -p "$HOME/.config/darkman"
    ${pkgs.coreutils}/bin/echo "dark" > "$HOME/.config/darkman/theme"
    
    # Also update the GTK dark preference which many Electron apps respect
    ${pkgs.dconf}/bin/dconf write /org/gnome/desktop/interface/color-scheme "'prefer-dark'"
  '';

  electron-light = pkgs.writeShellScriptBin "electron-light" ''
    # Create a config file that Electron apps can read
    ${pkgs.coreutils}/bin/mkdir -p "$HOME/.config/darkman"
    ${pkgs.coreutils}/bin/echo "light" > "$HOME/.config/darkman/theme"
    
    # Also update the GTK dark preference which many Electron apps respect
    ${pkgs.dconf}/bin/dconf write /org/gnome/desktop/interface/color-scheme "'prefer-light'"
  '';

in
{
  home.packages = with pkgs; [
    dark-mode-notify
    light-mode-notify
    gtk-dark
    gtk-light
    icon-dark
    icon-light
    kitty-dark
    kitty-light
    slack-dark
    slack-light
    dbeaver-dark
    dbeaver-light
    qt-dark
    qt-light
    electron-dark
    electron-light
  ];

  services.darkman = {
    enable = true;
    settings = {
      lat = 4.60971;  # Bogota latitude
      lng = -74.08175; # Bogota longitude
      dbusserver = true;
      portal = true;
      usegeoclue = false; # Set to true if you want automatic location detection
    };
    darkModeScripts = {
      gtk-theme = "${gtk-dark}/bin/gtk-dark";
      icon-theme = "${icon-dark}/bin/icon-dark";
      kitty-theme = "${kitty-dark}/bin/kitty-dark";
      slack-theme = "${slack-dark}/bin/slack-dark";
      dbeaver-theme = "${dbeaver-dark}/bin/dbeaver-dark";
      qt-theme = "${qt-dark}/bin/qt-dark";
      electron-apps = "${electron-dark}/bin/electron-dark";
      notify = "${dark-mode-notify}/bin/dark-mode-notify";
    };
    lightModeScripts = {
      gtk-theme = "${gtk-light}/bin/gtk-light";
      icon-theme = "${icon-light}/bin/icon-light";
      kitty-theme = "${kitty-light}/bin/kitty-light";
      slack-theme = "${slack-light}/bin/slack-light";
      dbeaver-theme = "${dbeaver-light}/bin/dbeaver-light";
      qt-theme = "${qt-light}/bin/qt-light";
      electron-apps = "${electron-light}/bin/electron-light";
      notify = "${light-mode-notify}/bin/light-mode-notify";
    };
  };
}