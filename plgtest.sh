#!/usr/bin/env bash

set -euo pipefail
source .env
# -------- Configuration --------
PORT="${PORT:-8000}"
LB_ADMIN_KEY="${LB_ADMIN_KEY:-LB_ADMIN_KEY}"
WORKDIR="$(pwd)"
LOGDIR="$WORKDIR"
CLOUDFLARED_BIN="$HOME/.local/bin/cloudflared"
# --------------------------------

# ---------- Install cloudflared once ----------
if [[ ! -x "$CLOUDFLARED_BIN" ]]; then
    echo "[+] Installing cloudflared into ~/.local/bin..."
    mkdir -p "$HOME/.local/bin"
    curl -fsSL \
        https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64 \
        -o "$CLOUDFLARED_BIN"
    chmod +x "$CLOUDFLARED_BIN"
fi

# Ensure ~/.local/bin is on PATH
export PATH="$HOME/.local/bin:$PATH"

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
    local LOG="$LOGDIR/cf${IDX}.log"
    local LAST_URL_FILE="$LOGDIR/last_${IDX}.url"

    echo "[+] Starting Cloudflared tunnel ${IDX}..."

    nohup cloudflared tunnel \
        --url "http://localhost:${PORT}" \
        > "$LOG" 2>&1 &

    while true; do
        URL=$(grep -Eo "https://[A-Za-z0-9.-]+\.trycloudflare\.com" "$LOG" | tail -n1 || true)

        if [[ -n "$URL" ]]; then
            LAST_URL=$(cat "$LAST_URL_FILE" 2>/dev/null || true)

            if [[ "$URL" != "$LAST_URL" ]]; then
                echo "[+] New Cloudflare URL (${IDX}): $URL"
                echo "$URL" > "$LAST_URL_FILE"

                (
                    while true; do
                        until curl -fsS -X POST \
                            -H "Content-Type: application/json" \
                            -H "X-Admin-Key: ${LB_ADMIN_KEY}" \
                            -d "{\"urls\":[\"$URL\"]}" \
                            https://fcdn.koyeb.app/add_cdn
                        do
                            sleep 2
                        done
                        echo "[✓] CDN registered (${IDX}): $URL"
                        sleep 300
                    done
                ) &
            fi
        fi

        sleep 2
    done
}

# Start two tunnels
for i in 1 2; do
    start_cloudflared "$i" &
done

echo "[✓] All services started."
wait
