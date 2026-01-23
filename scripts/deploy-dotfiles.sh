#!/usr/bin/env bash

# Deploy dotfiles from ./config to ~/.config
# Usage: ./deploy-dotfiles.sh

set -e  # Exit on error

SCRIPT_DIR="${HOME}/nixos/scripts"
SOURCE_DIR="${HOME}/nixos/configs"
TARGET_DIR="${HOME}/.config"

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${GREEN}=== Deploying dotfiles ===${NC}"
echo "Script: ${SCRIPT_DIR}"
echo "Source: ${SOURCE_DIR}"
echo "Target: ${TARGET_DIR}"
echo

# Check if source directory exists
if [ ! -d "${SOURCE_DIR}" ]; then
    echo -e "${RED}Error: Source directory ${SOURCE_DIR} does not exist${NC}"
    exit 1
fi

# Create target directory if it doesn't exist
mkdir -p "${TARGET_DIR}"

# Function to copy
deploy_config() {
    local config_name=$1
    local source="${SOURCE_DIR}/${config_name}"
    local target="${TARGET_DIR}/${config_name}"
    
    if [ ! -e "${source}" ]; then
        echo "${YELLOW}⚠ Skipping ${config_name} (not found in source)${NC}"
        return
    fi
    
    # Copy the config
    echo -e "${GREEN}✓ Deploying ${config_name}${NC}"
    cp -r "${source}" "${TARGET_DIR}/"
}

# Deploy common configs
# Add or remove configs as needed
CONFIGS=(
    "hypr"
    "quickshell"
    "matugen"
    # "waybar"
    "kitty"
    # "alacritty"
    # "foot"
    # "wofi"
     "rofi"
    # "dunst"
    # "mako"
)

deployed_count=0
for config in "${CONFIGS[@]}"; do
    if deploy_config "${config}"; then
        deployed_count=$((deployed_count + 1))
    fi
done

echo
echo -e "${GREEN}=== Deployment complete! ===${NC}"
echo -e "Deployed ${deployed_count} configurations"

# Optional: reload specific services
# echo
# read -p "Reload Hyprland config? (y/N) " -n 1 -r
# echo
# if [[ $REPLY =~ ^[Yy]$ ]]; then
#     if command -v hyprctl &> /dev/null; then
#         echo "Reloading Hyprland..."
#         hyprctl reload
#     else
#         echo -e "${YELLOW}hyprctl not found, skipping reload${NC}"
#     fi
# fi