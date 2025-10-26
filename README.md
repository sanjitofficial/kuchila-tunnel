# KUCHILA TUNNEL 🌀  
### Expose your local server to the internet — fast and simple.

KUCHILA TUNNEL is a lightweight bash utility that helps you instantly share your local web app, API, or file server with a public URL using tunneling tools like ngrok, Cloudflare Tunnel, localtunnel, or SSH (Serveo).

---

## 🧩 Features
- Auto-detect running local servers or enter ports manually  
- One-command setup for Linux, Termux, or WSL  
- Supports multiple tunnel providers (ngrok, Cloudflare, localtunnel, SSH)  
- Minimal interface, fast setup, beginner-friendly  

---

## ⚙️ Installation

### 1️⃣ Clone the repository
--> git clone https://github.com/sanjitofficial/kuchila-tunnel.git

--> cd kuchila-tunnel

### 2️⃣ Make scripts executable
--> chmod +x tunnel.sh install_tools.sh

### 3️⃣ Install dependencies

#### 🐧 Linux or WSL (Windows Subsystem for Linux)
Just run the installer:
--> ./install_tools.sh

This script automatically installs curl, unzip, ngrok, cloudflared, nodejs, npm, ssh, etc.

Note: WSL users follow the same steps — you’re inside Linux already.

#### 📱 Termux (Android)
The installer may not work on Termux. Use manual installation instead:
--> pkg update && pkg upgrade
--> pkg install nodejs openssh curl unzip
--> npm install -g localtunnel

Then install ARM-compatible binaries for ngrok and cloudflared:
# ngrok
--> curl -L https://bin.equinox.io/c/bNyj1mQVY4c/ngrok-v3-stable-linux-arm64.zip -o ngrok.zip
--> unzip ngrok.zip && mv ngrok $PREFIX/bin && rm ngrok.zip

# cloudflared
--> curl -L https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-arm64 -o cloudflared
--> mv cloudflared $PREFIX/bin && chmod +x $PREFIX/bin/cloudflared

---

## 🚀 Usage
Start any local server (for example):
--> python -m http.server 8000

Then run the tunnel:
--> ./tunnel.sh

Follow the prompts:
1. Choose a tunneling service  
2. Select a detected port or enter manually  
3. Copy the generated public URL and share it!  

Stop the tunnel anytime with Ctrl + C.

---

## 🌐 Available Tunneling Services

| Service | Highlights | Best For |
|----------|-------------|----------|
| ngrok | Reliable, rich features, needs authtoken for long sessions | General purpose |
| Cloudflare Tunnel | Secure and stable, Cloudflare account needed | Persistent or secure setups |
| localtunnel | Easiest setup, no account required | Quick demos |
| SSH (Serveo) | Uses SSH only, no installs | Limited systems / remote-only access |

---

## 🔑 Optional Configuration

### ngrok Authtoken
ngrok config add-authtoken <your_token_here>
Get your free token from https://dashboard.ngrok.com/get-started/your-authtoken

### Cloudflare Named Tunnels
For permanent tunnels, create a named tunnel via your Cloudflare dashboard.  
Docs: https://developers.cloudflare.com/cloudflare-one/connections/connect-apps/install-and-setup/tunnel-guide/

---

## 🧠 Troubleshooting

| Problem | Cause | Fix |
|----------|--------|-----|
| command not found | Missing dependency | Run ./install_tools.sh again |
| port already in use | Another process using same port | Stop that process or change port |
| connection refused | Wrong port or local server stopped | Check running server |
| permission denied | Missing executable flag | Run chmod +x tunnel.sh |

---

## 🧰 Developer Notes

Want to add a new tunneling service?

1. Open tunnel.sh  
2. Add a function:

run_mytunnel() {
    print_header
    echo "Starting MyTunnel..."
    local port=$(detect_and_select_port)
    mytunnel --port "$port"
}

3. Add "MyTunnel" to the options array in main()  
4. Add a matching case in the menu switch

The script will automatically detect and check for dependencies if you list them in REQUIRED_TOOLS.

---

## 🪪 License
MIT — Free to modify, use, and share.  
⚠️ You are exposing your local machine. Run only trusted servers and close tunnels when not in use.
