#!/usr/bin/env bash
set -euo pipefail

if [ "$#" -lt 2 ]; then
  echo "Usage: $0 -d <device_id> [extra flutter run args...]" >&2
  exit 64
fi

flutter run --machine "$@" 2>&1 | python3 tool/capture_vmservice.py
