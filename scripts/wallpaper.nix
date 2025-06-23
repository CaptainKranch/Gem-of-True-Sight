#{ pkgs }:
#pkgs.writeShellScriptBin "wallpaper-set" ''
#  
#  # Directory containing your wallpapers
#  wallpaper_dark_dir="/home/danielgm/.dots-flakes/wallpapers/light"
#  wallpaper_light_dir="/home/danielgm/.dots-flakes/wallpapers/dark"
#
#  # Check for argument
#  if [ "$1" = "light" ]; then
#    wallpaper=$(find "$wallpaper_light_dir" -type f | shuf -n 1)
#  elif [ "$1" = "dark" ]; then
#    wallpaper=$(find "$wallpaper_dark_dir" -type f | shuf -n 1)
#  fi
#
#  ${pkgs.pywal}/bin/wal -i "$wallpaper"
#
#  # Apply the colorscheme to Kitty
#  kitty @ set-colors --all ~/.cache/wal/colors-kitty.conf
#
#  # Ensure Kitty uses the new colorscheme for new instances
#  kitty_conf="$HOME/.config/kitty/kitty.conf"
#  temp_conf=$(mktemp)
#
#  # Check if the include line already exists
#  if ! grep -q "include ~/.cache/wal/colors-kitty.conf" "$kitty_conf"; then
#    echo "include ~/.cache/wal/colors-kitty.conf" >> "$temp_conf"
#  fi
#
#  # Append the rest of the original kitty.conf
#  cat "$kitty_conf" >> "$temp_conf"
#  mv "$temp_conf" "$kitty_conf"
#''
{ pkgs }:

pkgs.writeShellScriptBin "wallpaper-set" ''
  #!${pkgs.bash}/bin/bash
  set -euo pipefail # Exit on error, unset variable, or pipe failure

  # --- Configuration ---
  wallpaper_base_dir="/home/danielgm/.dots-flakes/wallpapers"
  light_wallpapers_dir="$wallpaper_base_dir/light"
  dark_wallpapers_dir="$wallpaper_base_dir/dark"

  # Define light mode hours (e.g., 6 AM to 5:59 PM)
  # %H is 00-23. So 6 (6 AM) to 17 (5 PM). Adjust if 6 PM should be light.
  light_start_hour=6
  light_end_hour=18 # Hour before which it's still light (e.g., 18 means up to 17:59)

  # --- Helper Functions ---
  # Selects a random wallpaper from a given directory
  # Usage: select_random_wallpaper <directory>
  select_random_wallpaper() {
    local dir="$1"
    if [ ! -d "$dir" ]; then
      # echo "Debug: Directory $dir does not exist." >&2 # Uncomment for debugging
      return 1 # Indicate failure
    fi

    local selected_wallpaper
    # Find image files (jpg, jpeg, png, webp), then pick one randomly.
    # 2>/dev/null suppresses "find: empty regular expression" if no matches for an -o clause
    selected_wallpaper=$(${pkgs.findutils}/bin/find "$dir" -type f \
      \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.webp" \) 2>/dev/null | \
      ${pkgs.coreutils}/bin/shuf -n 1)

    if [ -n "$selected_wallpaper" ]; then
      echo "$selected_wallpaper"
      return 0
    else
      # echo "Debug: No wallpapers found in $dir." >&2 # Uncomment for debugging
      return 1 # Indicate failure
    fi
  }

  # --- Main Logic ---
  target_mode=""
  wallpaper=""

  # Determine mode from argument or time
  mode_arg="''${1:-auto}" # Default to "auto" if no argument

  case "$mode_arg" in
    light)
      echo "Mode: light (manual)"
      target_mode="light"
      ;;
    dark)
      echo "Mode: dark (manual)"
      target_mode="dark"
      ;;
    auto)
      echo "Mode: auto (time-based)"
      current_hour=$(${pkgs.coreutils}/bin/date +%H)
      if [ "$current_hour" -ge "$light_start_hour" ] && [ "$current_hour" -lt "$light_end_hour" ]; then
        target_mode="light"
      else
        target_mode="dark"
      fi
      echo "Determined time-based mode: $target_mode"
      ;;
    random)
      echo "Mode: random (any wallpaper)"
      wallpaper=$(select_random_wallpaper "$wallpaper_base_dir")
      # If random from base dir fails, it will be handled by the final error check.
      ;;
    *)
      echo "Warning: Unknown argument '$1'. Defaulting to auto (time-based) selection." >&2
      # Recurse once with 'auto' or just duplicate logic for clarity:
      current_hour=$(${pkgs.coreutils}/bin/date +%H)
      if [ "$current_hour" -ge "$light_start_hour" ] && [ "$current_hour" -lt "$light_end_hour" ]; then
        target_mode="light"
      else
        target_mode="dark"
      fi
      echo "Determined time-based mode (fallback): $target_mode"
      ;;
  esac

  # Select wallpaper based on target_mode (if not already set by "random")
  if [ -z "$wallpaper" ]; then # if not already set by 'random' argument
    if [ "$target_mode" = "light" ]; then
      wallpaper=$(select_random_wallpaper "$light_wallpapers_dir")
      # Fallback for light mode: try dark if light folder is empty/missing
      if [ -z "$wallpaper" ]; then
        echo "Warning: No light wallpapers found in '$light_wallpapers_dir'. Trying dark wallpapers." >&2
        wallpaper=$(select_random_wallpaper "$dark_wallpapers_dir")
      fi
    elif [ "$target_mode" = "dark" ]; then
      wallpaper=$(select_random_wallpaper "$dark_wallpapers_dir")
      # Fallback for dark mode: try light if dark folder is empty/missing
      if [ -z "$wallpaper" ]; then
        echo "Warning: No dark wallpapers found in '$dark_wallpapers_dir'. Trying light wallpapers." >&2
        wallpaper=$(select_random_wallpaper "$light_wallpapers_dir")
      fi
    fi

    # Ultimate fallback if specific mode (light/dark) and its alternative failed:
    # Try random from the base wallpaper directory.
    if [ -z "$wallpaper" ]; then
      echo "Warning: No wallpapers found in theme-specific directories. Trying random from '$wallpaper_base_dir'." >&2
      wallpaper=$(select_random_wallpaper "$wallpaper_base_dir")
    fi
  fi


  # Check if a wallpaper was successfully selected
  if [ -z "$wallpaper" ]; then
    echo "Error: No wallpaper could be selected. Please check your wallpaper directory structure and files in:" >&2
    echo "  Base: $wallpaper_base_dir" >&2
    echo "  Light: $light_wallpapers_dir" >&2
    echo "  Dark: $dark_wallpapers_dir" >&2
    exit 1
  fi

  echo "Selected wallpaper: $wallpaper"

  # --- Apply Wallpaper and Colorscheme ---
  echo "Applying wallpaper with Pywal: $wallpaper"
  ${pkgs.pywal}/bin/wal -i "$wallpaper"

  # Apply the colorscheme to Kitty, if Kitty is running/installed
  if type kitty >/dev/null 2>&1; then
    echo "Applying colors to current Kitty instances..."
    kitty @ set-colors --all "$HOME/.cache/wal/colors-kitty.conf"

    # Ensure Kitty uses the new colorscheme for new instances
    kitty_conf_dir="$HOME/.config/kitty"
    kitty_conf_file="$kitty_conf_dir/kitty.conf"
    kitty_wal_include="include ~/.cache/wal/colors-kitty.conf" # Note: ~ is literal here

    # Create config directory and file if they don't exist
    ${pkgs.coreutils}/bin/mkdir -p "$kitty_conf_dir"
    ${pkgs.coreutils}/bin/touch "$kitty_conf_file"

    # Add the include line if it's not already there
    # Using grep -F for fixed string matching, -q for quiet
    if ! ${pkgs.gnugrep}/bin/grep -qF "$kitty_wal_include" "$kitty_conf_file"; then
      echo "Adding '$kitty_wal_include' to $kitty_conf_file"
      # Append the line to the kitty config file
      echo "$kitty_wal_include" >> "$kitty_conf_file"
    else
      echo "'$kitty_wal_include' already present in $kitty_conf_file"
    fi
  else
    echo "Kitty command not found, skipping Kitty configuration."
  fi

  echo "Wallpaper set successfully."
''
