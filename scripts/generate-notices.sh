#!/usr/bin/env bash
# Rebuild attribution from the checked-in media inventory; no network required.
set -euo pipefail
cd "$(dirname "$0")/.."
python3 - <<'PY'
import json
from pathlib import Path

entries = json.loads(Path('assets/media.json').read_text())
lines = ['# Third-party media notices', '', 'Generated from `assets/media.json` by `scripts/generate-notices.sh`.',
         'The MIT license covers original code, not the underlying third-party media.', '']
for kind, heading in [('artwork', 'Artworks'), ('music', 'Music'), ('sfx', 'Project-original sound effects')]:
    lines += ['## ' + heading, '']
    for entry in entries:
        if entry['kind'] != kind:
            continue
        lines += ['### ' + entry['title'], '',
                  f"- Creator: {entry['creator']}", f"- Date: {entry.get('date', '2026 (project original)')}",
                  f"- License: {entry['license']}"]
        if kind == 'sfx':
            lines += ['- Source: project original (no Commons source page)',
                      '- Changes: synthesized and encoded as bundled audio']
        else:
            lines += [f"- Commons source page: {entry['sourceUrl']}",
                      '- Changes: resized and re-encoded for the bundle' if kind == 'artwork'
                      else '- Changes: re-encoded for the bundle']
        lines += [f"- Bundled file: `{entry['file']}`", '']
Path('THIRD_PARTY_NOTICES.md').write_text('\n'.join(lines) + '\n')
PY
