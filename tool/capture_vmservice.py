import json
import re
import sys
from pathlib import Path

out_dir = Path(__file__).resolve().parent / 'vmservice'
out_dir.mkdir(parents=True, exist_ok=True)


def _sanitize(device_id: str) -> str:
    return re.sub(r'[^A-Za-z0-9]+', '_', device_id).strip('_')


for line in sys.stdin:
    line = line.strip()
    if not line:
        continue
    try:
        payload = json.loads(line)
    except json.JSONDecodeError:
        print(line)
        continue

    # pass through original JSON
    print(line)

    if not isinstance(payload, dict):
        continue

    params = payload.get('params') if isinstance(payload.get('params'), dict) else {}
    uri = params.get('vmServiceUri')
    device_id = params.get('deviceId')

    if uri:
        # always write last-used
        (out_dir / 'last').write_text(uri)
        if device_id:
            safe_id = _sanitize(device_id)
            target = out_dir / safe_id
            target.write_text(uri)
            msg = f"[vmservice] saved {uri} to {target}"
        else:
            msg = f"[vmservice] saved {uri} to {out_dir / 'last'}"
        sys.stderr.write(msg + "\n")
        sys.stderr.flush()
        print(msg)
