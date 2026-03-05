#!/usr/bin/env bash

# ─── User-configurable variables ───────────────────────────────────────────────
PYTHON_DIR="/Users/wupeihong/Desktop/nthu/graduate_project/graduate-project-backend"
PYTHON_BIN="python3"
FRONTEND_DIR="/Users/wupeihong/Desktop/nthu/graduate_project/graduate-project-frontend"
CHROME_URL="http://localhost:3000"
CHROME_PORT=3000
# ───────────────────────────────────────────────────────────────────────────────

PYTHON_PID=""
NPM_PID=""

cleanup() {
  echo ""
  echo "[start.sh] Shutting down..."
  [[ -n "$PYTHON_PID" ]] && kill "$PYTHON_PID" 2>/dev/null && echo "[python] stopped (pid $PYTHON_PID)"
  [[ -n "$NPM_PID" ]]    && kill "$NPM_PID"    2>/dev/null && echo "[npm] stopped (pid $NPM_PID)"
  exit 0
}

trap cleanup SIGINT SIGTERM

# ─── Start Python backend ───────────────────────────────────────────────────────
echo "[python] Starting main.py in $PYTHON_DIR..."
(
  cd "$PYTHON_DIR" || { echo "[python] ERROR: directory not found: $PYTHON_DIR"; exit 1; }
  "$PYTHON_BIN" main.py 2>&1 | while IFS= read -r line; do echo "[python] $line"; done
) &
PYTHON_PID=$!

# ─── Start frontend dev server ─────────────────────────────────────────────────
echo "[npm] Starting dev server in $FRONTEND_DIR..."
(
  cd "$FRONTEND_DIR" || { echo "[npm] ERROR: directory not found: $FRONTEND_DIR"; exit 1; }
  npm run dev 2>&1 | while IFS= read -r line; do echo "[npm] $line"; done
) &
NPM_PID=$!

# ─── Wait for frontend to be ready ─────────────────────────────────────────────
echo -n "[start.sh] Waiting for server on port $CHROME_PORT"
TIMEOUT=60
ELAPSED=0
until curl -s "http://localhost:$CHROME_PORT" > /dev/null 2>&1; do
  sleep 1
  ELAPSED=$((ELAPSED + 1))
  echo -n "."
  if [[ $ELAPSED -ge $TIMEOUT ]]; then
    echo ""
    echo "[start.sh] ERROR: server did not respond after ${TIMEOUT}s. Aborting."
    cleanup
  fi
done
echo ""
echo "[start.sh] Server is up."

# ─── Launch Chrome in kiosk mode ───────────────────────────────────────────────
echo "[chrome] Launching Chrome at $CHROME_URL..."
/Applications/Google\ Chrome.app/Contents/MacOS/Google\ Chrome \
  --kiosk \
  --no-first-run \
  --disable-infobars \
  --noerrdialogs \
  "$CHROME_URL" 2>&1 | while IFS= read -r line; do echo "[chrome] $line"; done &

# ─── Keep script alive (wait for Ctrl+C) ───────────────────────────────────────
wait
