#!/usr/bin/env bash
# Offline inventory and integrity verification for the bundled collection.
set -euo pipefail
cd "$(dirname "$0")/.."
python3 - <<'PY'
import hashlib, json, pathlib, sys

root = pathlib.Path('assets')
catalog = pathlib.Path('engine/Collection.js').read_text()
manifest = json.loads((root / 'media.json').read_text())
errors = []
listed = set()
sizes = {}
for entry in manifest:
    path = pathlib.Path(entry['file'])
    if path.as_posix() in listed:
        errors.append('Duplicate: ' + str(path))
    listed.add(path.as_posix())
    if not path.is_file():
        errors.append('Missing: ' + str(path))
        continue
    data = path.read_bytes()
    if len(data) != entry['bytes'] or hashlib.sha256(data).hexdigest() != entry['sha256']:
        errors.append('Integrity mismatch: ' + str(path))
    if path.as_posix() not in catalog:
        errors.append('Not referenced by Collection.js: ' + str(path))
    sizes[entry['kind']] = sizes.get(entry['kind'], 0) + len(data)
actual = {path.as_posix() for path in root.rglob('*') if path.is_file() and path.name != 'media.json'}
for path in sorted(actual - listed):
    errors.append('Unlisted: ' + path)
for path in sorted(listed - actual):
    errors.append('Listed but absent: ' + path)
for error in errors:
    print(error, file=sys.stderr)
for kind in ('artwork', 'music', 'sfx'):
    print(f'{kind}: {sizes.get(kind, 0)} bytes')
print(f'total: {sum(sizes.values())} bytes')
if errors:
    sys.exit(1)
print('Media inventory OK: ' + str(len(manifest)) + ' assets')
PY
