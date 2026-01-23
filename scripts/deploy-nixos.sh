#!/usr/bin/env bash

# Deploy NixOS configuration and rebuild system
# Usage: ./deploy-nixos.sh

set -e  # Exit on error

SCRIPT_DIR="${HOME}/nixos/scripts"
NIX_CONFIG_DIR="${SCRIPT_DIR}/.."
NIXOS_DIR="/etc/nixos"

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}=== NixOS Configuration Deployment ===${NC}"
echo

# Check if running with appropriate permissions
if [ "$EUID" -eq 0 ]; then 
    echo -e "${RED}Please run this script as a regular user (not with sudo)${NC}"
    echo "The script will request sudo when needed"
    exit 1
fi

# Check if source files exist
if [ ! -f "${NIX_CONFIG_DIR}/flake.nix" ]; then
    echo -e "${RED}Error: flake.nix not found in ${SCRIPT_DIR}${NC}"
    exit 1
fi

if [ ! -f "${NIX_CONFIG_DIR}/configuration.nix" ]; then
    echo -e "${RED}Error: configuration.nix not found in ${SCRIPT_DIR}${NC}"
    exit 1
fi

# Show diff before copying
echo -e "${BLUE}=== Changes to be applied ===${NC}"
echo
echo "--- flake.nix ---"
diff -u ${NIXOS_DIR}/flake.nix ${NIX_CONFIG_DIR}/flake.nix || true
echo
echo "--- configuration.nix ---"
diff -u ${NIXOS_DIR}/configuration.nix ${NIX_CONFIG_DIR}/configuration.nix || true
echo

# Ask for confirmation
read -p "Proceed with deployment? (y/N) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Deployment cancelled"
    exit 0
fi

# Copy configuration files
echo -e "${GREEN}✓ Copying flake.nix${NC}"
sudo cp "${NIX_CONFIG_DIR}/flake.nix" "${NIXOS_DIR}/flake.nix"

echo -e "${GREEN}✓ Copying configuration.nix${NC}"
sudo cp "${NIX_CONFIG_DIR}/configuration.nix" "${NIXOS_DIR}/configuration.nix"

# Copy any additional .nix files (like hardware-configuration.nix if present)
for file in "${NIX_CONFIG_DIR}"/*.nix; do
    filename=$(basename "$file")
    if [ "$filename" != "flake.nix" ] && [ "$filename" != "configuration.nix" ]; then
        if [ -f "$file" ]; then
            echo -e "${GREEN}✓ Copying ${filename}${NC}"
            sudo cp "$file" "${NIXOS_DIR}/${filename}"
        fi
    fi
done

echo
echo -e "${BLUE}=== Rebuilding NixOS ===${NC}"

# Rebuild the system
if sudo nixos-rebuild switch; then
    echo
    echo -e "${GREEN}=== System rebuild successful! ===${NC}"
else
    echo
    echo -e "${RED}=== Build failed! ===${NC}"
    exit 1
fi