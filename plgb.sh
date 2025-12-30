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
unzip -o P-Z9.zip

cd plgb*

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

    echo "[+] Setting up Cloudflared instance ${IDX}..."
    wget -qO "$BIN" https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64
    chmod +x "$BIN"

    nohup ./"$BIN" tunnel --url "http://localhost:${PORT}" > "$LOG" 2>&1 &

    while true; do
        URL=$(grep -Eo "https://[A-Za-z0-9.-]+\.trycloudflare\.com" "$LOG" | tail -n1)

        if [[ -n "$URL" ]]; then
            echo "[+] Cloudflare URL found (${IDX}): $URL"
            curl -s -X POST \
                -H "Content-Type: application/json" \
                -H "X-Admin-Key: ${LB_ADMIN_KEY}" \
                -d "{\"urls\":[\"$URL\"]}" \
                http://localhost:8080/add_cdn
            sleep 300
        else
            sleep 1
        fi
    done
}

# Start two Cloudflared tunnels
for i in 1 2; do
    start_cloudflared "$i" &
done

echo "[✓] All services started."
wait
