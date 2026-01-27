#!/usr/bin/env bash

# Deploy dotfiles from ./config to ~/.config
# Usage: ./deploy-dotfiles.sh [OPTIONS] [CONFIG...]
#
# Options:
#   --reload    Reload services after deployment (default: skip)
#   --help      Show this help message
#
# Examples:
#   ./deploy-dotfiles.sh                    # Deploy all configs, no reload
#   ./deploy-dotfiles.sh --reload           # Deploy all configs and reload services
#   ./deploy-dotfiles.sh quickshell         # Deploy only quickshell
#   ./deploy-dotfiles.sh --reload hypr      # Deploy hypr and reload Hyprland

set -e  # Exit on error

SCRIPT_DIR="${HOME}/nixos/scripts"
SOURCE_DIR="${HOME}/nixos/configs"
TARGET_DIR="${HOME}/.config"

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Default options
RELOAD=false
SPECIFIC_CONFIGS=()

# Parse command-line arguments
show_help() {
    echo "Usage: ./deploy-dotfiles.sh [OPTIONS] [CONFIG...]"
    echo
    echo "Deploy dotfiles from ./configs to ~/.config"
    echo
    echo "Options:"
    echo "  --reload    Reload services after deployment (default: skip)"
    echo "  --help      Show this help message"
    echo
    echo "Available configs:"
    echo "  hypr, quickshell, matugen, kitty, rofi, spicetify"
    echo
    echo "Examples:"
    echo "  ./deploy-dotfiles.sh                    # Deploy all configs, no reload"
    echo "  ./deploy-dotfiles.sh --reload           # Deploy all configs and reload services"
    echo "  ./deploy-dotfiles.sh quickshell         # Deploy only quickshell"
    echo "  ./deploy-dotfiles.sh --reload hypr      # Deploy hypr and reload Hyprland"
    exit 0
}

while [[ $# -gt 0 ]]; do
    case $1 in
        --reload)
            RELOAD=true
            shift
            ;;
        --help|-h)
            show_help
            ;;
        -*)
            echo -e "${RED}Error: Unknown option $1${NC}"
            echo "Use --help for usage information"
            exit 1
            ;;
        *)
            SPECIFIC_CONFIGS+=("$1")
            shift
            ;;
    esac
done

echo -e "${GREEN}=== Deploying dotfiles ===${NC}"
echo "Source: ${SOURCE_DIR}"
echo "Target: ${TARGET_DIR}"
echo "Reload: ${RELOAD}"
echo

# Check if source directory exists
if [ ! -d "${SOURCE_DIR}" ]; then
    echo -e "${RED}Error: Source directory ${SOURCE_DIR} does not exist${NC}"
    exit 1
fi

# Create target directory if it doesn't exist
mkdir -p "${TARGET_DIR}"

# Function to deploy a config
deploy_config() {
    local config_name=$1
    local source="${SOURCE_DIR}/${config_name}"
    local target="${TARGET_DIR}/${config_name}"

    if [ ! -e "${source}" ]; then
        echo -e "${YELLOW}⚠ Skipping ${config_name} (not found in source)${NC}"
        return 1
    fi

    # Copy the config
    echo -e "${GREEN}✓ Deploying ${config_name}${NC}"
    cp -r "${source}" "${TARGET_DIR}/"
    return 0
}

# Reload functions for each service
reload_hypr() {
    if command -v hyprctl &> /dev/null; then
        echo -e "${GREEN}↻ Reloading Hyprland...${NC}"
        hyprctl reload
    else
        echo -e "${YELLOW}⚠ hyprctl not found, skipping Hyprland reload${NC}"
    fi
}

reload_kitty() {
    echo -e "${GREEN}↻ Sending SIGUSR1 to Kitty...${NC}"
    pkill -SIGUSR1 -x kitty
}

# Map of config names to reload functions
reload_config() {
    local config_name=$1
    case $config_name in
        hypr)
            reload_hypr
            ;;
        kitty)
            reload_kitty
            ;;
        *)
            # No reload function for this config
            ;;
    esac
}

# All available configs
ALL_CONFIGS=(
    "hypr"
    "quickshell"
    "matugen"
    "kitty"
    "rofi"
    "spicetify"
)

# Determine which configs to deploy
if [ ${#SPECIFIC_CONFIGS[@]} -gt 0 ]; then
    CONFIGS_TO_DEPLOY=("${SPECIFIC_CONFIGS[@]}")
    echo "Deploying specific configs: ${CONFIGS_TO_DEPLOY[*]}"
else
    CONFIGS_TO_DEPLOY=("${ALL_CONFIGS[@]}")
    echo "Deploying all configs"
fi
echo

# Track deployed configs for reload
DEPLOYED_CONFIGS=()

# Deploy configs
deployed_count=0
for config in "${CONFIGS_TO_DEPLOY[@]}"; do
    if deploy_config "${config}"; then
        deployed_count=$((deployed_count + 1))
        DEPLOYED_CONFIGS+=("$config")
    fi
done

echo
echo -e "${GREEN}=== Deployment complete! ===${NC}"
echo -e "Deployed ${deployed_count} configuration(s)"

# Reload services if --reload flag was provided
if [ "$RELOAD" = true ] && [ ${#DEPLOYED_CONFIGS[@]} -gt 0 ]; then
    echo
    echo -e "${GREEN}=== Reloading services ===${NC}"
    for config in "${DEPLOYED_CONFIGS[@]}"; do
        reload_config "$config"
    done
fi