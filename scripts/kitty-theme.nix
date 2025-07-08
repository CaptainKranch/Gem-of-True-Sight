{ pkgs }:

pkgs.writeShellScriptBin "kitty-theme" ''
  #!${pkgs.bash}/bin/bash
  set -euo pipefail

  # --- Configuration ---
  declare -A themes=(
    # Dark themes
    ["tokyonight"]="Tokyo Night"
    ["tokyonight-storm"]="Tokyo Night Storm"
    ["tokyonight-moon"]="Tokyo Night Moon"
    ["dracula"]="Dracula"
    ["gruvbox-dark"]="Gruvbox Dark"
    ["catppuccin-mocha"]="Catppuccin Mocha"
    ["catppuccin-macchiato"]="Catppuccin Macchiato"
    ["catppuccin-frappe"]="Catppuccin Frappe"
    ["nord"]="Nord"
    ["onedark"]="One Dark"
    ["material"]="Material"
    ["cyberpunk"]="Cyberpunk"
    
    # Light themes
    ["tokyonight-day"]="Tokyo Night Day"
    ["gruvbox-light"]="Gruvbox Light"
    ["catppuccin-latte"]="Catppuccin Latte"
    ["github-light"]="GitHub Light"
    ["solarized-light"]="Solarized Light"
    ["rosepine-dawn"]="Rosé Pine Dawn"
    ["everforest-light"]="Everforest Light Soft"
  )

  # --- Helper Functions ---
  show_usage() {
    echo "Usage: $(basename "$0") [COMMAND] [THEME]"
    echo ""
    echo "Commands:"
    echo "  list                List all available themes"
    echo "  set <theme>         Set a specific theme"
    echo "  random              Set a random theme"
    echo "  random-dark         Set a random dark theme"
    echo "  random-light        Set a random light theme"
    echo "  current             Show current theme (if tracked)"
    echo "  interactive         Launch interactive theme picker"
    echo ""
    echo "Theme shortcuts:"
    for key in "''${!themes[@]}"; do
      echo "  $key -> ''${themes[$key]}"
    done | sort
  }

  get_theme_name() {
    local input="$1"
    # Check if it's a shortcut
    if [[ -n "''${themes[$input]:-}" ]]; then
      echo "''${themes[$input]}"
    else
      # Return as-is for full theme names
      echo "$input"
    fi
  }

  set_theme() {
    local theme_name="$1"
    echo "Setting Kitty theme to: $theme_name"
    
    # Apply theme to all running instances
    if ${pkgs.kitty}/bin/kitty +kitten themes --reload-in=all "$theme_name"; then
      # Save current theme for reference
      mkdir -p "$HOME/.config/kitty"
      echo "$theme_name" > "$HOME/.config/kitty/.current-theme"
      echo "Theme applied successfully!"
    else
      echo "Error: Failed to set theme. Theme might not exist." >&2
      echo "Use '$(basename "$0") list' to see available themes." >&2
      exit 1
    fi
  }

  # --- Main Logic ---
  case "''${1:-}" in
    list)
      echo "Available theme shortcuts:"
      for key in "''${!themes[@]}"; do
        echo "  $key -> ''${themes[$key]}"
      done | sort
      echo ""
      echo "You can also use any theme name from kitty's full theme list."
      echo "Run '$(basename "$0") interactive' to browse all themes."
      ;;
      
    set)
      if [[ -z "''${2:-}" ]]; then
        echo "Error: Please specify a theme name." >&2
        show_usage
        exit 1
      fi
      theme_name=$(get_theme_name "$2")
      set_theme "$theme_name"
      ;;
      
    random)
      # Get random theme from our curated list
      keys=("''${!themes[@]}")
      random_key="''${keys[RANDOM % ''${#keys[@]}]}"
      theme_name="''${themes[$random_key]}"
      echo "Selected random theme: $theme_name"
      set_theme "$theme_name"
      ;;
      
    random-dark)
      # Filter dark themes
      dark_themes=()
      for key in "''${!themes[@]}"; do
        case "$key" in
          tokyonight|tokyonight-storm|tokyonight-moon|dracula|gruvbox-dark|catppuccin-mocha|catppuccin-macchiato|catppuccin-frappe|nord|onedark|material|cyberpunk)
            dark_themes+=("$key")
            ;;
        esac
      done
      random_key="''${dark_themes[RANDOM % ''${#dark_themes[@]}]}"
      theme_name="''${themes[$random_key]}"
      echo "Selected random dark theme: $theme_name"
      set_theme "$theme_name"
      ;;
      
    random-light)
      # Filter light themes
      light_themes=()
      for key in "''${!themes[@]}"; do
        case "$key" in
          tokyonight-day|gruvbox-light|catppuccin-latte|github-light|solarized-light|rosepine-dawn|everforest-light)
            light_themes+=("$key")
            ;;
        esac
      done
      random_key="''${light_themes[RANDOM % ''${#light_themes[@]}]}"
      theme_name="''${themes[$random_key]}"
      echo "Selected random light theme: $theme_name"
      set_theme "$theme_name"
      ;;
      
    current)
      if [[ -f "$HOME/.config/kitty/.current-theme" ]]; then
        echo "Current theme: $(cat "$HOME/.config/kitty/.current-theme")"
      else
        echo "No theme tracking found. Theme was likely set outside this script."
      fi
      ;;
      
    interactive|"")
      echo "Launching interactive theme picker..."
      ${pkgs.kitty}/bin/kitty +kitten themes
      ;;
      
    -h|--help|help)
      show_usage
      ;;
      
    *)
      # Try to interpret as theme name
      theme_name=$(get_theme_name "$1")
      set_theme "$theme_name"
      ;;
  esac
''