#!/usr/bin/env bash

# ─── 路徑設定 ───────────────────────────────────────────────────────────────────
FRONTEND_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$FRONTEND_DIR")"
KINECT_DIR="$PROJECT_DIR/graduate-project-kinect"
PYTHON_BIN="python3"
# ───────────────────────────────────────────────────────────────────────────────

FRONTEND_PID=""
KINECT_PID=""

cleanup() {
  echo ""
  echo "[start_all] Shutting down..."
  [[ -n "$KINECT_PID" ]]   && kill "$KINECT_PID"   2>/dev/null && echo "[kinect] stopped (pid $KINECT_PID)"
  [[ -n "$FRONTEND_PID" ]] && kill "$FRONTEND_PID" 2>/dev/null && echo "[frontend] stopped (pid $FRONTEND_PID)"
  exit 0
}

trap cleanup SIGINT SIGTERM

# ─── 啟動 Kinect main.py ────────────────────────────────────────────────────────
echo "[kinect] Starting main.py in $KINECT_DIR..."
(
  cd "$KINECT_DIR" || { echo "[kinect] ERROR: directory not found: $KINECT_DIR"; exit 1; }
  "$PYTHON_BIN" main.py 2>&1 | while IFS= read -r line; do echo "[kinect] $line"; done
) &
KINECT_PID=$!

# ─── 啟動 Frontend start.sh ────────────────────────────────────────────────────
echo "[frontend] Starting start.sh in $FRONTEND_DIR..."
(
  cd "$FRONTEND_DIR" || { echo "[frontend] ERROR: directory not found: $FRONTEND_DIR"; exit 1; }
  bash start.sh 2>&1 | while IFS= read -r line; do echo "[frontend] $line"; done
) &
FRONTEND_PID=$!

echo "[start_all] Both services started. Press Ctrl+C to stop all."

# ─── 等待任一子程序結束 ──────────────────────────────────────────────────────────
wait -n 2>/dev/null || wait
echo "[start_all] A service exited. Cleaning up..."
cleanup
