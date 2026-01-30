#!/usr/bin/env bash
set -euo pipefail

if [ "$#" -lt 2 ]; then
  echo "Usage: $0 -d <device_id> [extra flutter run args...]" >&2
  exit 64
fi

# Extract device id from args
DEVICE_ID=""
ARGS=("$@")
for ((i=0; i<${#ARGS[@]}; i++)); do
  if [ "${ARGS[$i]}" = "-d" ] && [ $((i+1)) -lt ${#ARGS[@]} ]; then
    DEVICE_ID="${ARGS[$((i+1))]}"
    break
  fi
done

if [ -z "$DEVICE_ID" ]; then
  echo "Missing -d <device_id>" >&2
  exit 64
fi

SAFE_ID="$(echo "$DEVICE_ID" | sed -E 's/[^A-Za-z0-9]+/_/g' | sed -E 's/^_+|_+$//g')"
OUT_FILE="tool/vmservice/${SAFE_ID}"
mkdir -p tool/vmservice

TMP_LOG="$(mktemp)"
cleanup() {
  rm -f "$TMP_LOG"
}
trap cleanup EXIT

# Start a background tail to capture the ws://.../ws URL once
( tail -f "$TMP_LOG" | grep -m1 -oE 'ws://[^ ]+/ws' > "$OUT_FILE" && echo "[vmservice] saved $(cat "$OUT_FILE") to $OUT_FILE" > /dev/tty ) &
TAIL_PID=$!

# Run flutter in a PTY so hot-reload keys still work (macOS script)
script -q "$TMP_LOG" flutter run "$@"

# Clean up tail if still running
if ps -p "$TAIL_PID" >/dev/null 2>&1; then
  kill "$TAIL_PID" >/dev/null 2>&1 || true
fi

if [ ! -f "$OUT_FILE" ]; then
  echo "[vmservice] did not capture VM service URL" >&2
  exit 1
fi
