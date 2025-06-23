{ inputs, outputs, ... }: {
  imports = [
    ./global
    # Terminal programs
    ../../programs/terminal/kitty
    ../../programs/terminal/nushell
    ../../programs/terminal/lazygit
    ../../programs/terminal/wormhole
    ../../programs/terminal/unzip
    ../../programs/terminal/nvim
    ../../programs/terminal/btop
    ../../programs/terminal/starship
    ../../programs/terminal/claude-code
    # Desktop prgroams
    ../../programs/desktop/slack
    ../../programs/desktop/pcmanfm
    ../../programs/desktop/libreoffice
    ../../programs/desktop/obsidian
    ../../programs/desktop/discord
    ../../programs/desktop/thunderbird
    ../../programs/desktop/chromium
    ../../programs/desktop/teams
    ../../programs/desktop/zoom
    ../../programs/desktop/telegram
    ../../programs/desktop/dbeaver
    ../../programs/desktop/teamspeak
  ];
}

