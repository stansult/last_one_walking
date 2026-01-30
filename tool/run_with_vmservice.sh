#!/usr/bin/env bash
set -euo pipefail

if [ "$#" -lt 2 ]; then
  echo "Usage: $0 -d <device_id> [extra flutter run args...]" >&2
  exit 64
fi

# Always resolve output paths relative to this script's directory,
# so running from any CWD still writes to tool/vmservice/<device>.
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OUT_DIR="${SCRIPT_DIR}/vmservice"
mkdir -p "$OUT_DIR"

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
OUT_FILE="${OUT_DIR}/${SAFE_ID}"

TMP_LOG="$(mktemp)"
cleanup() {
  rm -f "$TMP_LOG"
}
trap cleanup EXIT

# Optional: parent-side notifier (doesn't affect saving)

# Capture the ws://.../ws URL once.
# Disable pipefail in this subshell because grep -m1 causes tail to get SIGPIPE.
(
  set +o pipefail
  tail -f "$TMP_LOG" | grep -m1 -oE 'ws://[^ ]+/ws' > "$OUT_FILE"
  # Signal parent to print (best-effort)
) &
TAIL_PID=$!

# Run flutter in a PTY so hot-reload keys still work (macOS/BSD script)
script -q "$TMP_LOG" flutter run "$@"

# Clean up tail if still running
if ps -p "$TAIL_PID" >/dev/null 2>&1; then
  kill "$TAIL_PID" >/dev/null 2>&1 || true
fi

if [ ! -f "$OUT_FILE" ] || [ ! -s "$OUT_FILE" ]; then
  echo "[vmservice] did not capture VM service URL" >&2
  exit 1
fi
