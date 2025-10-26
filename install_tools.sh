#!/bin/bash

# install_tools.sh - Installer for tunnel.sh dependencies.

# --- Style and Color Definitions ---
C_RESET='\033[0m'
C_RED='\033[0;31m'
C_GREEN='\033[0;32m'
C_YELLOW='\033[0;33m'
C_BLUE='\033[0;34m'
C_CYAN='\033[0;36m'
C_BOLD='\033[1m'
C_BOLD_RED='\033[1;31m'
C_LINK='\033[1;34m'
C_KEY='\033[1;32m'

# --- Helper Functions ---

detect_distro() {
    # ... (omitted for brevity, no changes)
}

install_with_package_manager() {
    # ... (omitted for brevity, no changes)
}

install_ngrok() {
    # ... (omitted for brevity, no changes)
}

install_cloudflared() {
    # ... (omitted for brevity, no changes)
}

# --- Main Installation Logic ---

echo -e "${C_BLUE}--- Tunneling Tools Installer ---${C_RESET}"
detect_distro

# Install essential dependencies
install_with_package_manager "curl" "curl"
install_with_package_manager "unzip" "unzip"
install_with_package_manager "xdg-open" "xdg-utils"

# Install main tools
install_ngrok
install_cloudflared
install_with_package_manager "npm" "npm"
install_with_package_manager "ssh" "openssh-client"

# Install localtunnel via npm
if command -v npm > /dev/null && ! command -v lt > /dev/null; then
    echo -e "${C_YELLOW}Attempting to install localtunnel via npm...${C_RESET}"
    if [ "$PKG_MANAGER" == "pkg" ]; then # No sudo for termux
        npm install -g localtunnel
    else
        echo -e "${C_BLUE}Press ${C_KEY}[Enter]${C_BLUE} to provide sudo privileges for installation, or ${C_KEY}[Ctrl+C]${C_BLUE} to cancel.${C_RESET}"
        read
        sudo npm install -g localtunnel
    fi
    if ! command -v lt > /dev/null; then
        echo -e "${C_BOLD_RED}Failed to install localtunnel. Please run 'npm install -g localtunnel' manually.${C_RESET}"
    else
        echo -e "${C_GREEN}✔ Successfully installed localtunnel!${C_RESET}"
    fi
fi

echo -e "\n${C_GREEN}Installation script finished. Please re-run ./tunnel.sh${C_RESET}"