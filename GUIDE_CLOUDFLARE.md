# Cloudflare Tunnel Login Guide

**What is the Cloudflare login?**

Cloudflare Tunnel provides a highly secure way to connect your local server to the internet. To ensure this security, it needs to associate your `cloudflared` client with your Cloudflare account. This is done through a one-time browser login.

**Step-by-Step Login Instructions:**

1.  **A browser window will open** to authorize the tunnel.

2.  You will be prompted to **log in** to your Cloudflare account.

3.  **IMPORTANT: AFTER LOGGING IN:**
    - If you are not on a page asking to **"Authorize"** a tunnel, you must **copy the URL from the terminal** and paste it into the same browser window again. This happens sometimes if your login session had expired.

4.  Select a domain from your account and click the **"Authorize"** button to complete the process.

Once you do this once, a certificate file is saved, and you will not need to log in via the browser again on this computer.
