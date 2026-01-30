#!/usr/bin/env bash
set -euo pipefail

if [ "$#" -lt 2 ]; then
  echo "Usage: $0 <device_id> <cmd[:value]> [cmd[:value] ...]" >&2
  echo "Example: $0 emulator-5554 set_speed:2.0 set_miles:1.5 set_started:1" >&2
  exit 64
fi

device_id="$1"
shift

safe_id="$(echo "$device_id" | sed -E 's/[^A-Za-z0-9]+/_/g' | sed -E 's/^_+|_+$//g')"
vmfile="tool/.vmservice.${safe_id}"
if [ ! -f "$vmfile" ]; then
  echo "Missing $vmfile. Run: tool/run_with_vmservice.sh -d $device_id" >&2
  exit 64
fi

vmuri="$(cat "$vmfile")"

map_cmd() {
  case "$1" in
    set_speed) echo "ext.last_one_walking.setSpeed" ;;
    set_miles) echo "ext.last_one_walking.setMiles" ;;
    set_warnings_left) echo "ext.last_one_walking.setWarningsLeft" ;;
    set_grace) echo "ext.last_one_walking.setGrace" ;;
    set_erase) echo "ext.last_one_walking.setErase" ;;
    set_started) echo "ext.last_one_walking.setStarted" ;;
    stop) echo "ext.last_one_walking.stop" ;;
    *) echo "" ;;
  esac
}

for arg in "$@"; do
  cmd="${arg%%:*}"
  value=""
  if [[ "$arg" == *":"* ]]; then
    value="${arg#*:}"
  fi

  ext="$(map_cmd "$cmd")"
  if [ -z "$ext" ]; then
    echo "Unknown command: $cmd" >&2
    exit 64
  fi

  if [ -n "$value" ]; then
    dart run tool/call_extension.dart "$vmuri" "$ext" "$value"
  else
    dart run tool/call_extension.dart "$vmuri" "$ext"
  fi

done
