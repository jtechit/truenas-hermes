# truenas-hermes

A standalone TrueNAS Apps deployment kit for the **Hermes Agent** (`nousresearch/hermes-agent`), with optional Tailscale sidecar support.

---

## Prerequisites

- **TrueNAS SCALE Electric Eel** or newer
- **Custom App support** enabled in TrueNAS (Apps → Settings → Advanced Settings → Enable Custom Apps)
- A **ZFS dataset** pre-created for persistent storage (see [Dataset Setup](#dataset-setup))
- `docker compose` v2 or `podman-compose` available on the system running the commands

---

## Quick Start

```bash
git clone https://github.com/jtechit/truenas-hermes.git
cd truenas-hermes
chmod +x setup.sh
./setup.sh          # interactive wizard — writes .env
make up             # start services (use 'make up-ts' for Tailscale)
```

---

## Dataset Setup

Create a ZFS dataset in the TrueNAS UI before running the setup wizard:

1. Navigate to **Storage → Datasets → Add Dataset**
2. Choose your pool (e.g. `tank`)
3. Create a dataset at a path such as `/mnt/tank/otto/data`
4. Note the full path — you will enter it when prompted by `setup.sh`

> **Recommended path:** `/mnt/<pool>/otto/data`

The setup wizard runs `mkdir -p` on the path you supply, but the parent dataset must already exist in TrueNAS.

---

## Accessing the Dashboard

Once services are running, open the dashboard in your browser:

```
http://<truenas-ip>:9119
```

Log in with the username and password you set during `./setup.sh`.

### Restricting to a Specific Interface

To expose the dashboard only on a particular network interface, set `DASHBOARD_HOST` in `.env` to that interface's IP address:

```bash
DASHBOARD_HOST=192.168.1.10
DASHBOARD_PORT=9119
```

Then restart the services:

```bash
make down && make up
```

---

## Tailscale Setup

Tailscale is fully opt-in via a Compose override file. It adds a `tailscale` sidecar that shares its network namespace with `hermes-dashboard`, exposing the dashboard on your Tailscale network.

### Steps

1. **Generate a Tailscale auth key** — log in to the [Tailscale admin console](https://login.tailscale.com/admin/settings/keys), create a reusable auth key.

2. **Add the key to `.env`:**

   ```bash
   TS_AUTHKEY=tskey-auth-...
   TS_HOSTNAME=otto        # hostname visible on your Tailnet
   ```

3. **Enable `/dev/net/tun` in TrueNAS** — in the TrueNAS Custom App settings for this app, add `/dev/net/tun` under **Device Passthrough**. This is required for Tailscale's kernel networking mode (`TS_USERSPACE=false`).

4. **Start services with Tailscale:**

   ```bash
   make up-ts
   ```

5. **Access the dashboard via Tailscale:**

   ```
   http://<tailscale-ip>:9119
   ```

> **Note:** When running with Tailscale, the standard LAN port (`9119`) is no longer published. Access is exclusively through the Tailscale network.

---

## Updating

Pull the latest images and recreate containers:

```bash
make update
```

---

## Environment Variable Reference

| Variable | Required | Description |
|---|---|---|
| `OTTO_DATA_PATH` | ✅ Required | Absolute path to TrueNAS ZFS dataset (bind-mounted to `/opt/data`) |
| `HERMES_UID` | ✅ Required | UID for file ownership inside the container (default: `1000`) |
| `HERMES_GID` | ✅ Required | GID for file ownership inside the container (default: `1000`) |
| `ANTHROPIC_API_KEY` | ✅ Required | Anthropic API key for Claude access |
| `HERMES_DASHBOARD_BASIC_AUTH_USERNAME` | ✅ Required | Dashboard login username |
| `HERMES_DASHBOARD_BASIC_AUTH_PASSWORD` | ✅ Required | Dashboard login password |
| `HERMES_DASHBOARD_BASIC_AUTH_SECRET` | ✅ Required | Session secret (min 32 chars, alphanumeric) |
| `DASHBOARD_HOST` | Optional | Interface IP to bind the dashboard port (default: `0.0.0.0`) |
| `DASHBOARD_PORT` | Optional | Host port for the dashboard (default: `9119`) |
| `TELEGRAM_BOT_TOKEN` | Optional | Telegram bot token |
| `TELEGRAM_ALLOWED_USERS` | Optional | Comma-separated Telegram user IDs allowed to use the bot |
| `DISCORD_BOT_TOKEN` | Optional | Discord bot token |
| `DISCORD_ALLOWED_USERS` | Optional | Comma-separated Discord user IDs allowed to use the bot |
| `SLACK_BOT_TOKEN` | Optional | Slack bot OAuth token |
| `SLACK_APP_TOKEN` | Optional | Slack app-level token (socket mode) |
| `SLACK_ALLOWED_USERS` | Optional | Comma-separated Slack user IDs allowed to use the bot |
| `TS_AUTHKEY` | Optional¹ | Tailscale auth key (required when using `docker-compose.tailscale.yml`) |
| `TS_HOSTNAME` | Optional | Tailscale hostname for this node (default: `otto`) |
| `TS_EXTRA_ARGS` | Optional | Extra arguments passed to the `tailscale up` command |

> ¹ Required only when starting with `make up-ts` (Tailscale overlay).