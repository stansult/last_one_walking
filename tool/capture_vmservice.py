import json
import sys
from pathlib import Path

out_dir = Path(__file__).resolve().parent

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
        (out_dir / '.vmservice').write_text(uri)
        if device_id:
            (out_dir / f'.vmservice.{device_id}').write_text(uri)
            sys.stderr.write(f"[vmservice] saved {uri} to {out_dir / ('.vmservice.' + device_id)}\n")
        else:
            sys.stderr.write(f"[vmservice] saved {uri} to {out_dir / '.vmservice'}\n")
        sys.stderr.flush()
