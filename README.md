KUCHILA TUNNEL — Simple local → public tunneling launcher

A small, opinionated bash wrapper to quickly expose a local server (HTTP/SSH/etc.) to the public internet using tools like ngrok, cloudflared, localtunnel or ssh (Serveo-style).
Minimal, clear, and focused — for demos, webhook testing, quick sharing, or development collaboration.

What this does (short)

Detects running local servers (common ports) or accepts a manual port.

Lets you pick a tunneling backend (ngrok / Cloudflare Tunnel / localtunnel / SSH).

Starts the chosen tunnel and shows the public forwarding URL.

Small helper for dev workflows — not a full orchestration tool.

Features

Auto-detect local servers (common ports) or manual port input.

Installer helper (Linux) to fetch required CLI tools.

Support for ngrok, cloudflared, localtunnel (lt), and SSH-based tunnels.

Simple prompts — designed for quick one-off sharing.

Requirements

bash (POSIX shell compatible)

One of the tunneling tools (installer script can set up on Linux)

curl, unzip, node / npm (for localtunnel) depending on chosen backend

Termux users: Termux provides a Linux-like environment but package names & installer steps differ. See Termux notes below.

Installation (quick)
1) Grab the repo
   
$git clone https://github.com/sanjitofficial/kuchila-tunnel.git
$cd kuchila-tunnel

3) Make scripts executable (one-time)
$chmod +x tunnel.sh install_tools.sh

4) Install dependencies

Linux (Debian/Ubuntu / Fedora / Arch-like)
Run the installer (it will try to detect distro and install common tools).

$./install_tools.sh

Or install manually: `curl`, `unzip`, `nodejs`/`npm`, `openssh-client`, etc.

- **WSL (Windows Subsystem for Linux)**  
Use WSL's package manager exactly like Linux. Install WSL first (`wsl --install`) and run the same installer inside the WSL distro.

- **Termux (Android)** — *special notes*
Termux uses `pkg` and often ARM binaries. Installer script is **not** guaranteed to work. Recommended manual steps:
```sh
pkg update && pkg upgrade
pkg install nodejs openssh curl unzip
npm install -g localtunnel
# install ngrok/cloudflared for ARM if available — download ARM builds and move to $PREFIX/bin


If binaries are not ARM-compatible, download appropriate releases from upstream and place them into $PREFIX/bin with chmod +x.

Quick start (use)

Start your local server (e.g., python -m http.server 8000).

Run:

./tunnel.sh


Follow the menu:

Pick a tunneling service.

Select a detected running port or enter one manually.

The script will launch the tunnel and print the public URL (e.g., https://abc.ngrok.io -> http://localhost:8000).

Stop the tunnel with Ctrl+C.

Services (short comparison)
Service	When to use
ngrok	Best all-rounder. Feature-rich; use an authtoken for stable sessions.
Cloudflare Tunnel	Enterprise-grade, secure, good for persistent/named tunnels (requires Cloudflare account).
localtunnel (lt)	Fast & zero-account setup. Good for quick demos.
SSH/Serveo-style	No client install (if allowed); uses ssh tunnel — handy on locked-down systems.
Advanced notes
ngrok authtoken

To avoid short anonymous sessions or to use subdomains:

Create a free account at ngrok.

Copy the authtoken from the dashboard.

When prompted by the script, paste the token — it will run ngrok config add-authtoken <token>.

Cloudflare persistent tunnels

Cloudflare quick tunnels are ephemeral. For a permanent named tunnel, follow Cloudflare docs to create a named tunnel and configure DNS. The script supports the quick tunnel flow; named tunnels require manual Cloudflare setup.

Troubleshooting (common)

Command not found — installer failed or binary not in PATH. Re-run installer or place binary in /usr/local/bin (or $PREFIX/bin on Termux).

Port already in use — choose another port or stop the conflicting service.

Public URL opens but shows Connection Refused — local server not running on the selected port or a firewall blocks access.

Termux: binary fails — check CPU arch (arm/arm64/x86) and download correct binary release.

Minimal developer guide (how to add a backend)

Add a function to tunnel.sh that:

Prompts/selects a port,

Builds the command to start the tunnel,

Starts it (foreground) so Ctrl+C stops it cleanly.

Add the tool name in the options array in main() and handle it in case statements.
(Keep it small — follow existing ngrok/cloudflared patterns.)

Contributing

Keep changes small and focused.

Use bash -n and shellcheck while developing.

Submit PRs that update REQUIRED_TOOLS and add clear usage examples.

License

MIT — copy, modify, share. Use responsibly (you're exposing local services to the internet).

Last words (hacker-sane)

This repo is a lightweight helper — not a long-running production gateway. Use it for demos and dev workflows. Know what you expose, secure what matters, and keep your authtokens private.
