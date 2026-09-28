#!/usr/bin/env bash
# Rebuild attribution from the checked-in media inventory; no network required.
set -euo pipefail
cd "$(dirname "$0")/.."
python3 - <<'PY'
import json
from pathlib import Path

entries = json.loads(Path('assets/media.json').read_text())
lines = ['# Third-party media notices', '', 'Generated from `assets/media.json` by `scripts/generate-notices.sh`.',
         'MIT covers original code and associated documentation, not bundled media. Project-original sound effects are dedicated under CC0 1.0; third-party music recordings are CC0, and artworks are public domain.', '']
for kind, heading in [('artwork', 'Artworks'), ('music', 'Music'), ('sfx', 'Project-original sound effects')]:
    lines += ['## ' + heading, '']
    for entry in entries:
        if entry['kind'] != kind:
            continue
        lines += ['### ' + entry['title'], '']
        if kind == 'music' and ' — ' in entry['creator']:
            composer, performer = entry['creator'].split(' — ', 1)
            lines += [f'- Composer: {composer}', f'- Performer: {performer}']
        else:
            lines += [f"- Creator: {entry['creator']}"]
        fallback_date = {'artwork': 'Date unknown', 'music': 'Recording date unknown',
                         'sfx': '2026 (project original)'}[kind]
        lines += [f"- Date: {entry.get('date', fallback_date)}",
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
