# KUCHILA TUNNEL: The Complete Guide

## 1. Introduction

Welcome! This guide will walk you through everything you need to know about KUCHILA TUNNEL.

### What is this tool?
This tool is a simple, powerful script that helps you expose a local server (like a web application running on your own computer) to the public internet. This is incredibly useful for:
- **Demonstrating a web project** to a client without deploying it.
- **Testing webhooks** from services like Stripe, GitHub, or Twilio.
- **Collaborating with teammates** on a project that runs locally.
- **Temporarily sharing a file** from a local HTTP server.

The script acts as a friendly user interface for powerful tunneling services like `ngrok`, `Cloudflare Tunnel`, and others.

### How does it work?
Your computer is usually behind a router and firewall, making it inaccessible from the public internet. A tunneling service creates a secure, encrypted connection from your computer to its public servers. It then gives you a public URL (e.g., `https://random-name.ngrok.io`) that anyone on the internet can visit. When someone accesses that URL, the service "tunnels" the traffic to the local server running on your machine.

---

## 2. Quick Start for Beginners

Getting started is easy. The tool is designed to guide you every step of the way.

### Step 1: Make the Scripts Executable
If you haven't already, you need to give your computer permission to run the scripts. You only need to do this once.
```sh
chmod +x tunnel.sh install_tools.sh
```

### Step 2: Run the Tool
Execute the main script in your terminal:
```sh
./tunnel.sh
```

### Step 3: Follow the On-Screen Instructions
- **Automated Installation:** The first time you run the script, it will check if all the necessary software (like `ngrok`, `cloudflared`, etc.) is installed. If anything is missing, it will offer to run the installer script. Just press `y` and Enter to proceed. The installer will automatically download and set up all required tools for you.
- **Service Menu:** Once all dependencies are installed, you will see a menu asking which service you want to use.
- **Port Selection:** The script will then automatically detect any servers already running on your machine and present you with a numbered list.
    - **Select a detected port:** Simply enter the number corresponding to the server you want to share.
    - **Manual Entry:** If your server isn't listed or you want to specify a different port, choose the "Enter a port number manually" option.

### Example: Sharing a Python Web Server
1.  Start your Python web server. Let's say it's running on port 8000.
2.  Run the tool: `./tunnel.sh`
3.  From the service menu, choose `1` for `ngrok`.
4.  The script will detect your server and show it in a list, for example: `2. Port 8000 (python)`.
5.  Enter `2` to select your Python server.
6.  The script will start `ngrok`, and you will see a public URL (e.g., `Forwarding https://some-random-name.ngrok.io -> http://localhost:8000`).
7.  **You can now share this URL with anyone!**

To stop the tunnel, go back to the terminal and press `Ctrl+C`.

---

## 3. Understanding the Tunneling Services

The tool offers several services, each with its own strengths.

| Service           | Pros                                        | Cons                               | Best For                                                              |
|-------------------|---------------------------------------------|------------------------------------|-----------------------------------------------------------------------|
| **ngrok**         | Very popular, reliable, feature-rich free tier. | Anonymous sessions time out after a few hours. | Quick, reliable, general-purpose tunneling and webhook testing.       |
| **Cloudflare Tunnel** | Extremely secure, stable, from a trusted company. | Requires a Cloudflare account and a one-time browser login. | Users who already have a Cloudflare account or need very secure tunnels. |
| **localtunnel**   | Very simple, no account needed.             | Can be less reliable than other services. | The absolute quickest way to get a public URL with no setup.          |
| **Serveo.net**    | **No client install needed!** Uses standard SSH. | Can be less reliable; may have more latency. | Situations where you cannot install any new software on your machine. |

---

## 4. Advanced Usage

Once you're comfortable with the basics, you can leverage more powerful features.

### Using an `ngrok` Authtoken
The script will prompt you to add an `ngrok` authtoken if it's not already configured.
- **Why?** It removes the session time limit on the free tier and allows you to use other features like custom subdomains.
- **How?**
    1.  Sign up for a free account at [ngrok.com](https://ngrok.com).
    2.  Find your authtoken on your dashboard: [dashboard.ngrok.com/get-started/your-authtoken](https://dashboard.ngrok.com/get-started/your-authtoken)
    3.  The next time you run the tool and choose `ngrok`, paste the token in when prompted. It's a one-time setup.

### Persistent Tunnels with Cloudflare
The script uses Cloudflare's "quick tunnels," which generate a random URL each time. For a stable, permanent URL, you can create a "named tunnel." This requires more setup within your Cloudflare dashboard but is perfect for long-term projects. Follow the official [Cloudflare Tunnel documentation](https://developers.cloudflare.com/cloudflare-one/connections/connect-apps/install-and-setup/tunnel-guide/) to set one up.

### Security: A Word of Caution
When you run this tool, you are punching a hole from the public internet to your local machine. **Only run servers from trusted sources and be aware of the risks.** Do not leave a tunnel running unattended for long periods if you don't need to. Services like Cloudflare Tunnel are designed with a "zero-trust" security model, making them a safer choice for sensitive applications.

---

## 5. For Developers: Extending the Tool

The script is designed to be easily modified.

### How to Add a New Tunneling Service
Let's say you want to add a new service called `super-tunnel`.

1.  **Create a Function:** Open `tunnel.sh` in a text editor. Create a new bash function for your service, following the existing structure.
    ```bash
    run_supertunnel() {
        print_header
        echo -e "${C_CYAN}--- Using SuperTunnel ---${C_RESET}"
        local port=$(detect_and_select_port) # Re-use the port helper function
        echo -e "\n${C_GREEN}🚀 Starting SuperTunnel...${C_RESET}"
        # The command to start the new service
        supertunnel --port "$port"
    }
    ```

2.  **Update the Menu:** Find the `main()` function at the bottom of the script.
    - Add the new service name to the `options` array.
    - Add a new `case` for it in the `select` statement.
    ```bash
    # In main()
    options=("ngrok" "Cloudflare Tunnel" "localtunnel" "Serveo.net (SSH)" "SuperTunnel" "Exit") # Add new option
    
    select opt in "${options[@]}"; do
        case $opt in
            # ... existing cases ...
            "SuperTunnel")
                run_supertunnel # Call your new function
                break
                ;; 
            # ...
        esac
    done
    ```

3.  **Add Dependencies (Optional):** If your new service requires a command-line tool (like `supertunnel`), add it to the `REQUIRED_TOOLS` array at the top of `tunnel.sh`. The script will then automatically check if it's installed.
    ```bash
    # At the top of tunnel.sh
    REQUIRED_TOOLS=("ngrok" "cloudflared" "ssh" "npm" "lt" "supertunnel")
    ```

---

## 6. Troubleshooting

- **"Command not found" error:** This means a required tool was not installed correctly. Run `./tunnel.sh` again and allow it to run the installer. If the problem persists, there may be an issue with your system's configuration (like the `PATH` environment variable).
- **"Port already in use" error:** This error comes from the tunneling service itself. It means another application on your computer is already using the port you specified. Stop the other application or choose a different port.
- **Connection Refused:** If you can access the public URL but see a "Connection Refused" error, it usually means:
    - Your local server is not actually running.
    - Your local server is running on a *different port* than the one you told the tool to use.
    - A firewall on your computer is blocking the connection (less common).

---

## 7. Platform-Specific Instructions

This tool is a `bash` script, so its setup varies by operating system.

### Linux (Recommended)

This tool was designed and built for Linux. It works out-of-the-box on virtually all modern Linux distributions (like Ubuntu, Fedora, Arch Linux, etc.). The automatic installer is tailored for Linux and handles all dependencies for you.

**Simply follow the [Quick Start for Beginners](#2-quick-start-for-beginners) section.**

### Windows (via WSL - Windows Subsystem for Linux)

The scripts **cannot** be run in the standard Windows Command Prompt (cmd) or PowerShell.

The recommended and only supported way to use this tool on Windows is with the **Windows Subsystem for Linux (WSL)**. WSL allows you to run a real Linux environment directly on Windows.

1.  **Install WSL:** If you don't have it, follow Microsoft's official guide to install WSL. A single command in your PowerShell (as Administrator) is usually all you need:
    ```powershell
wsl --install
    ```
    We recommend choosing **Ubuntu** as your Linux distribution when prompted.

2.  **Open your WSL Terminal:** Once installed, open your Ubuntu (or other) Linux terminal from the Start Menu.

3.  **Follow the Linux Instructions:** Inside WSL, you are running Linux! You can now follow the [Quick Start for Beginners](#2-quick-start-for-beginners) section exactly as written.

### Termux (Android)

Termux provides a Linux environment on Android, so the main `tunnel.sh` script works well. However, the automatic installer (`install_tools.sh`) **will not work** because Termux uses a different package manager (`pkg`).

You must install the required tools manually.

1.  **Open Termux and Update Packages:**
    ```sh
pkg update && pkg upgrade
    ```

2.  **Install Core Dependencies:**
    ```sh
pkg install nodejs openssh curl unzip
    ```

3.  **Install `localtunnel`:**
    ```sh
npm install -g localtunnel
    ```

4.  **Install `ngrok` and `cloudflared`:**
    You need to download the versions made for the ARM architecture used by most phones.

    ```bash
    # Install ngrok (ARM64)
    curl -L https://bin.equinox.io/c/bNyj1mQVY4c/ngrok-v3-stable-linux-arm64.zip -o ngrok.zip
unzip ngrok.zip
mv ngrok $PREFIX/bin
rm ngrok.zip

# Install cloudflared (ARM64)
curl -L https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-arm64 -o cloudflared
mv cloudflared $PREFIX/bin
chmod +x $PREFIX/bin/cloudflared
    ```

5.  **Run the Tool:** Once all the dependencies are installed manually, you can run the main script as usual:
    ```sh
./tunnel.sh
    ```
