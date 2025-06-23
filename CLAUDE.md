# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This is a personal NixOS configuration using Nix Flakes that manages multiple systems including desktops, servers, and macOS machines. The configuration is organized around a flake-based architecture with per-host configurations and home-manager for user environments.

## System Management Commands

### Build and Switch
```bash
# Build and switch NixOS system configuration
sudo nixos-rebuild switch --flake .#hostname --show-trace

# Switch home-manager configuration
home-manager switch --flake .#username@hostname --show-trace

# Build without switching (for testing)
sudo nixos-rebuild build --flake .#hostname --show-trace
```

### Available Hosts
- `yonaguni` - Main desktop (NixOS)
- `medellin` - Homelab server (NixOS) 
- `sabanea` - Secondary system (NixOS)
- `la13` - Hetzner cloud server (NixOS)
- `neayork` - Mac Mini (nix-darwin)

### Home Manager Users
- `captainkranch@yonaguni`
- `captainkranch@medellin`
- `captainkranch@sabanea`
- `energybeeworker@la13`
- `housebeeworker@la13`

## Architecture

### Directory Structure
- `flake.nix` - Main flake configuration with inputs and outputs
- `hosts/` - System-level NixOS configurations per machine
- `home/` - User-level home-manager configurations per machine
- `modules/` - Reusable system modules (dwm, dmenu, firefox customizations)
- `programs/` - Application configurations organized by desktop/terminal
- `services/` - Service definitions for homelab setup
- `secrets/` - Age-encrypted secrets using agenix

### Key Components
- **Window Manager**: dwm (patched with custom modules in `modules/dwm/`)
- **Terminal**: kitty with nushell
- **Editor**: Neovim with extensive plugin configurations
- **Secrets Management**: agenix for encrypted secrets
- **Multi-platform**: Supports both NixOS and nix-darwin (macOS)

### Service Architecture (medellin homelab)
The medellin host runs various self-hosted services:
- Grafana + Prometheus + Loki for monitoring
- Docker services via compose files in `services/src/`
- Caddy reverse proxy for service routing
- Services include: Immich, Hoarder, Plex, databases, etc.

## Development Workflow

### Testing Changes
1. Build configuration locally before switching: `sudo nixos-rebuild build --flake .#hostname`
2. Use `--show-trace` flag for detailed error information
3. Test home-manager changes: `home-manager build --flake .#user@host`

### Secret Management
- Secrets are encrypted with agenix and stored in `secrets/`
- Secret keys are referenced in configurations and decrypted at runtime
- Environment files are generated from secrets in systemd services

### Custom Modules
- dwm and dmenu are built from source with custom patches in `modules/`
- Firefox configurations include custom CSS and user.js
- Neovim plugins are organized by functionality with custom themes