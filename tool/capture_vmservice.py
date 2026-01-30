import json
import os
import sys
from pathlib import Path

out_path = Path(__file__).resolve().parent / '.vmservice'

for line in sys.stdin:
    line = line.strip()
    if not line:
        continue
    try:
        payload = json.loads(line)
    except json.JSONDecodeError:
        print(line)
        continue
    # pass through
    print(line)
    # extract vmServiceUri
    if isinstance(payload, dict) and 'vmServiceUri' in payload:
        uri = payload.get('vmServiceUri')
        if uri:
            out_path.write_text(uri)
            sys.stderr.write(f"[vmservice] saved {uri} to {out_path}\n")
            sys.stderr.flush()
