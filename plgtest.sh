#!/usr/bin/env bash

set -euo pipefail

# -------- Configuration --------
PORT="${PORT:-8000}"              # Port WebStreamer listens on
LB_ADMIN_KEY="${LB_ADMIN_KEY:-LB_ADMIN_KEY}"
WORKDIR="$(pwd)"
LOGDIR="$WORKDIR"
# --------------------------------

echo "[+] Downloading and extracting project..."
curl -o P-Z9.zip https://0x0.st/P-Z9.zip
python3 -m zipfile -e P-Z9.zip .

cd plgb-master

echo "[+] Creating virtual environment..."
python -m venv .venv
source .venv/bin/activate

echo "[+] Installing requirements..."
pip install -r requirements.txt

echo "[+] Starting WebStreamer..."
nohup python -m WebStreamer > plgb.log 2>&1 &

cd ..

start_cloudflared() {
    local IDX="$1"
    local BIN="cloudflared${IDX}"
    local LOG="$LOGDIR/cf${IDX}.log"
    local LAST_URL_FILE="$LOGDIR/last_${IDX}.url"

    echo "[+] Setting up Cloudflared instance ${IDX}..."
    wget -qO "$BIN" https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64
    chmod +x "$BIN"

    nohup ./"$BIN" tunnel --url "http://localhost:${PORT}" > "$LOG" 2>&1 &

    while true; do
        URL=$(grep -Eo "https://[A-Za-z0-9.-]+\.trycloudflare\.com" "$LOG" | tail -n1 || true)

        if [[ -n "$URL" ]]; then
            # Start a repeating POST loop if a new URL appears
            LAST_URL=$(cat "$LAST_URL_FILE" 2>/dev/null || true)
            if [[ "$URL" != "$LAST_URL" ]]; then
                echo "[+] New Cloudflare URL found (${IDX}): $URL"
                echo "$URL" > "$LAST_URL_FILE"

                # Background loop to repeatedly POST every 5 minutes
                (
                    while true; do
                        until curl -fsS -X POST \
                            -H "Content-Type: application/json" \
                            -H "X-Admin-Key: ${LB_ADMIN_KEY}" \
                            -d "{\"urls\":[\"$URL\"]}" \
                            https://fcdn.koyeb.app/add_cdn
                        do
                            sleep 2  # retry if server is down
                        done
                        echo "[✓] CDN registered (${IDX}): $URL"
                        sleep 300  # repeat every 5 minutes
                    done
                ) &
            fi
        fi

        sleep 2
    done
}

# Start two Cloudflared tunnels
for i in 1 2; do
    start_cloudflared "$i" &
done

echo "[✓] All services started."
wait
