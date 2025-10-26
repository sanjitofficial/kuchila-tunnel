#!/bin/bash

# tunnel.sh - A user-friendly script to expose local servers to the internet.

# --- Configuration ---
REQUIRED_TOOLS=("ngrok" "cloudflared" "ssh" "npm" "lt" "xdg-open")
INSTALLER_SCRIPT="install_tools.sh"

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

# Prints a styled header for the script.
print_header() {
    clear
    echo -e "${C_CYAN}======================================================${C_RESET}"
    echo -e "          ${C_BOLD}${C_YELLOW}🚀  KUCHILA TUNNEL  🚀${C_RESET}"
    echo -e "${C_CYAN}======================================================${C_RESET}"
    echo -e "       Your Personal Tunneling & Forwarding Assistant${C_RESET}"
    echo
}

# Checks if all required command-line tools are installed.
check_dependencies() {
    echo -e "${C_YELLOW}🔎 Verifying required tools...${C_RESET}"
    MISSING_DEPS=()

    for tool in "${REQUIRED_TOOLS[@]}"; do
        if ! command -v "$tool" > /dev/null; then
            echo -e "${C_RED}✖ ${tool} is not installed.${C_RESET}"
            MISSING_DEPS+=("$tool")
        else
            echo -e "${C_GREEN}✔ ${tool} is installed.${C_RESET}"
        fi
    done

    if [ ${#MISSING_DEPS[@]} -ne 0 ]; then
        echo
        echo -e "${C_BOLD_RED}Some required tools are missing!${C_RESET}"
        echo "This script requires all tools to be installed to function correctly."
        
        if [ -f "$INSTALLER_SCRIPT" ]; then
            read -p "Would you like to execute the installer script (${INSTALLER_SCRIPT}) now? (y/n): " choice
            if [[ "$choice" == "y" || "$choice" == "Y" ]]; then
                echo -e "${C_YELLOW}Executing the installer...${C_RESET}"
                bash "$INSTALLER_SCRIPT"
                echo
                echo -e "${C_GREEN}Installer script finished.${C_RESET}"
                echo -e "${C_YELLOW}Please restart the script.${C_RESET}"
                exit 0
            else
                echo -e "${C_BOLD_RED}Cannot proceed without the required tools. Please install them manually and restart the script.${C_RESET}"
                exit 1
            fi
        else
            echo -e "${C_YELLOW}The installer script '${INSTALLER_SCRIPT}' was not found in the current directory.${C_RESET}"
            echo -e "${C_BOLD_RED}Please install the missing tools manually and restart the script.${C_RESET}"
            exit 1
        fi
    fi
    echo -e "\n${C_GREEN}✅ All dependencies are satisfied!${C_RESET}\n"
    sleep 1
}

# Prompts user for a valid port number.
prompt_for_manual_port() {
    local port
    while true; do
        read -p "Please specify the local port number of your service (e.g., 8000): " port
        if [[ "$port" =~ ^[0-9]+$ && "$port" -gt 0 && "$port" -le 65535 ]]; then
            echo "$port"
            return
        else
            echo -e "${C_BOLD_RED}Invalid input. Please enter a valid port number (1-65535).${C_RESET}"
        fi
    done
}

# Detects listening ports and allows user to select one or enter manually.
detect_and_select_port() {
    echo -e "${C_YELLOW}🔎 Detecting active listening ports...${C_RESET}" >&2
    
    mapfile -t listening_ports < <(ss -ltn | grep LISTEN | awk '{print $4}' | sed 's/.*://' | sort -un)

    options=("Enter a port number manually")
    for port in "${listening_ports[@]}"; do
        options+=("Port ${port}")
    done

    if [ ${#options[@]} -le 1 ]; then
        echo -e "${C_YELLOW}No active listening ports were automatically detected.${C_RESET}" >&2
        echo -e "${C_YELLOW}Please ensure a local server or application is running on a specific port.${C_RESET}" >&2
        prompt_for_manual_port
        return
    fi

    echo -e "\n${C_BOLD}Please select the port you wish to forward:${C_RESET}" >&2
    PS3="Please enter your selection: "
    select opt in "${options[@]}"; do
        case $opt in
            "Enter a port number manually")
                prompt_for_manual_port
                return
                ;; 
            *)
                port=$(echo "$opt" | awk '{print $2}')
                if [[ " ${listening_ports[@]} " =~ " ${port} " ]]; then
                    echo "$port"
                    return
                else
                    echo -e "${C_BOLD_RED}Invalid selection. Please choose a number from the list.${C_RESET}" >&2
                fi
                ;; 
        esac
    done
}

# --- Authentication Handlers ---

handle_ngrok_auth() {
    if grep -q "authtoken" ~/.config/ngrok/ngrok.yml 2>/dev/null || grep -q "authtoken" ~/.ngrok2/ngrok.yml 2>/dev/null; then
        return 0
    fi

    while true; do
        print_header
        echo -e "${C_YELLOW}An ngrok authtoken is recommended for longer, more stable sessions.${C_RESET}"
        echo -e "If you don't have a token, or to see other options, leave the input blank and press ${C_KEY}Enter${C_RESET}."
        read -p "Please enter your ngrok authtoken: " authtoken

        if [ -n "$authtoken" ]; then
            ngrok config add-authtoken "$authtoken"
            echo -e "${C_GREEN}✔ ngrok authtoken saved.${C_RESET}"
            sleep 1
            break
        else
            PS3="Please choose an option: "
            options=("Re-enter token" "Read setup guide" "Open ngrok website to get token" "Continue without token")
            select opt in "${options[@]}"; do
                case $opt in
                    "Re-enter token")
                        break
                        ;;
                    "Read setup guide")
                        clear
                        cat "GUIDE_NGROK.md"
                        echo
                        read -p "Press [Enter] to return to the menu..."
                        break
                        ;;
                    "Open ngrok website to get token")
                        xdg-open https://dashboard.ngrok.com/get-started/your-authtoken
                        break
                        ;;
                    "Continue without token")
                        return 0
                        ;;
                    *)
                        echo -e "${C_BOLD_RED}Invalid option '$REPLY'.${C_RESET}"
                        ;;
                esac
            done
        fi
    done
}

handle_cloudflare_auth() {
    if [ -f ~/.cloudflared/cert.pem ]; then
        return 0
    fi

    while true; do
        print_header
        echo -e "${C_YELLOW}Cloudflare Tunnel requires a one-time browser login to authenticate your device.${C_RESET}"
        PS3="Please choose an option: "
        options=("Proceed with browser login" "Read setup guide" "Open Cloudflare website" "Exit")
        select opt in "${options[@]}"; do
            case $opt in
                "Proceed with browser login")
                    clear
                    echo -e "${C_CYAN}--------------------------------------------------------${C_RESET}"
                    echo -e "${C_BOLD}${C_YELLOW}         Important Login Instructions${C_RESET}"
                    echo -e "${C_CYAN}--------------------------------------------------------${C_RESET}"
                    echo
                    echo -e "1. A browser window will open to authorize the tunnel."
                    echo
                    echo -e "2. You will be prompted to log in to your Cloudflare account."
                    echo
                    echo -e "${C_BOLD_RED}3. AFTER LOGGING IN:${C_RESET}"
                    echo -e "   If you are not on a page asking to ${C_BOLD}Authorize${C_RESET} a tunnel,"
                    echo -e "   you must ${C_BOLD}copy the URL from the terminal${C_RESET} and paste it"
                    echo -e "   into the same browser window again."
                    echo
                    echo -e "4. Select a domain and click ${C_BOLD}Authorize${C_RESET} to complete the process."
                    echo
                    read -p "Press [Enter] to begin..."

                    cloudflared tunnel login
                    if [ -f ~/.cloudflared/cert.pem ]; then
                        echo -e "${C_GREEN}✔ Cloudflare login successful.${C_RESET}"
                        sleep 2
                        return 0
                    else
                        echo -e "${C_BOLD_RED}Cloudflare login appears to have failed or was cancelled.${C_RESET}"
                        sleep 2
                    fi
                    break
                    ;;
                "Read setup guide")
                    clear
                    cat "GUIDE_CLOUDFLARE.md"
                    echo
                    read -p "Press [Enter] to return to the menu..."
                    break
                    ;;
                "Open Cloudflare website")
                    xdg-open https://dash.cloudflare.com
                    break
                    ;;
                "Exit")
                    exit 0
                    ;;
                *)
                    echo -e "${C_BOLD_RED}Invalid option '$REPLY'.${C_RESET}"
                    ;;
            esac
        done
    done
}

# --- Tunneling Service Functions ---

run_ngrok() {
    handle_ngrok_auth
    print_header
    echo -e "${C_CYAN}--- Using ngrok ---${C_RESET}"
    local port=$(detect_and_select_port)
    local command="ngrok http $port"

    read -p "Do you want to specify a custom domain? (y/n): " choice
    if [[ "$choice" == "y" || "$choice" == "Y" ]]; then
        echo -e "${C_YELLOW}Note: Custom domains on ngrok typically require a paid plan.${C_RESET}"
        read -p "Enter your desired hostname (e.g., my-app.ngrok.app): " custom_url
        if [ -n "$custom_url" ]; then
            command="ngrok http --hostname \"$custom_url\" $port"
        fi
    fi

    echo -e "\n${C_GREEN}🚀 Initiating ngrok tunnel for http://localhost:${port}...${C_RESET}"
    echo -e "Press ${C_KEY}Ctrl+C${C_RESET} in the terminal to terminate the tunnel."
    echo "---------------------------------------------------"
    eval $command
}

run_cloudflare() {
    handle_cloudflare_auth
    print_header
    echo -e "${C_CYAN}--- Using Cloudflare Tunnel ---${C_RESET}"
    local port=$(detect_and_select_port)
    echo -e "\n${C_GREEN}🚀 Initiating Cloudflare tunnel for http://localhost:${port}...${C_RESET}"
    echo -e "Press ${C_KEY}Ctrl+C${C_RESET} in the terminal to terminate the tunnel."
    echo "---------------------------------------------------"
    cloudflared tunnel --url "http://localhost:${port}"
}

run_localtunnel() {
    print_header
    echo -e "${C_CYAN}--- Using localtunnel ---${C_RESET}"
    echo "localtunnel provides a public URL with a random subdomain."
    local port=$(detect_and_select_port)
    local command="lt --port $port"

    read -p "Do you want to request a custom subdomain? (y/n): " choice
    if [[ "$choice" == "y" || "$choice" == "Y" ]]; then
        read -p "Enter your desired subdomain (e.g., my-cool-app): " custom_subdomain
        if [ -n "$custom_subdomain" ]; then
            command="lt --port $port --subdomain \"$custom_subdomain\""
        fi
    fi

    echo -e "\n${C_GREEN}🚀 Initiating localtunnel for http://localhost:${port}...${C_RESET}"
    echo -e "Press ${C_KEY}Ctrl+C${C_RESET} in the terminal to terminate the tunnel."
    echo "---------------------------------------------------"
    eval $command
}

run_serveo() {
    print_header
    echo -e "${C_CYAN}--- Using Serveo (via SSH) ---${C_RESET}"
    echo "Serveo forwards your port using a simple SSH command. No client installation is required."
    local port=$(detect_and_select_port)
    echo -e "\n${C_GREEN}🚀 Initiating Serveo tunnel for http://localhost:${port}...${C_RESET}"
    echo "Your public URL will be a subdomain of serveo.net."
    echo -e "Press ${C_KEY}Ctrl+C${C_RESET} in the terminal to terminate the tunnel."
    echo "---------------------------------------------------"
    ssh -R 80:localhost:"$port" serveo.net
}


# --- Main Script Logic ---

main() {
    print_header
    check_dependencies

    echo -e "${C_YELLOW}${C_BOLD}Which tunneling service would you like to use?${C_RESET}"
    
    PS3="Please enter your choice (1-5): "
    
    options=("ngrok" "Cloudflare Tunnel" "localtunnel" "Serveo.net (SSH)" "Exit")
    
    select opt in "${options[@]}"; do
        case $opt in
            "ngrok")
                run_ngrok
                break
                ;;
            "Cloudflare Tunnel")
                run_cloudflare
                break
                ;;
            "localtunnel")
                run_localtunnel
                break
                ;;
            "Serveo.net (SSH)")
                run_serveo
                break
                ;;
            "Exit")
                echo "Goodbye!"
                exit 0
                ;;
            *)
                echo -e "${C_BOLD_RED}Invalid option '$REPLY'. Please choose a number from 1 to 5.${C_RESET}"
                ;;
        esac
    done
}

# Execute the main function
main