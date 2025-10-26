# Ngrok Authtoken Setup Guide

**Why do you need an authtoken?**

While ngrok can be used anonymously, providing an authtoken from a free account gives you significant benefits:
- **Longer Session Times:** Anonymous tunnels time out after a few hours. Tunnels with an authtoken last much longer.
- **Custom Subdomains:** Unlocks the ability to use custom subdomains (if they are available).
- **More Connections:** A higher number of connections per minute are allowed.

**Step-by-Step Guide to get your Authtoken:**

1.  **Create a Free Account:**
    - Open your web browser and navigate to the ngrok signup page: `https://dashboard.ngrok.com/signup`
    - Sign up using your email or a Google/GitHub account.

2.  **Find Your Authtoken:**
    - After signing in, you will be taken to your ngrok dashboard.
    - On the left-hand menu, navigate to `Your Authtoken`. The page URL is: `https://dashboard.ngrok.com/get-started/your-authtoken`
    - Your personal authtoken will be displayed prominently on this page. It's a long string of characters.

3.  **Copy the Authtoken:**
    - Click the "Copy" button next to the token to copy it to your clipboard.

4.  **Paste into the Tool:**
    - Go back to the terminal where KUCHILA TUNNEL is running.
    - When prompted, paste the authtoken you just copied and press Enter.

The tool will save your authtoken, and you will not need to enter it again on this computer.
