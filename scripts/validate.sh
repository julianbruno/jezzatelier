#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
qt=/usr/lib/qt6/bin
shell_path="${OMARCHY_PATH:-/usr/share/omarchy}/shell"
printf '\n== Launcher safety tests ==\n'
bash tests/test-install-launcher.sh
printf '\n== Qt 6 tests ==\n'
QT_QPA_PLATFORM=offscreen "$qt/qmltestrunner" -input tests -import . -import "$shell_path"
printf '\n== Qt 6 QML lint ==\n'
mapfile -d '' files < <(find . -type f -name '*.qml' -not -path './.git/*' -print0 | sort -z)
# qmllint emits a baseline uncreatable PanelWindow warning for the shell entry point.
# Capture each result to distinguish that exact diagnostic from every other warning.
for file in "${files[@]}"; do
  result=$("$qt/qmllint" -I "$shell_path" "$file" 2>&1) || { printf '%s\n' "$result"; exit 1; }
  if [[ -n "$result" ]]; then
    expected=$'Warning: ./JezzAtelier.qml:55:3: Type PanelWindow is not creatable. [uncreatable-type]\n  PanelWindow {\n  ^^^^^^^^^^^'
    if [[ "$file" != './JezzAtelier.qml' || "$result" != "$expected" ]]; then
      printf 'Unexpected lint diagnostic: %s\n' "$result" >&2; exit 1
    fi
    printf 'Allowed baseline: %s\n' "${result%%$'\n'*}"
  fi
done
printf 'QML lint OK: %s files\n' "${#files[@]}"
printf '\n== Omarchy manifest ==\n'
if command -v omarchy >/dev/null 2>&1; then omarchy plugin validate .; echo 'Manifest OK'; else echo 'Skipped: omarchy unavailable'; fi
printf '\n== Media inventory ==\n'
scripts/check-media.sh
printf '\n== Repository hygiene ==\n'
python3 - <<'PY'
import json, pathlib, subprocess, re
root = pathlib.Path('.')
tracked = [pathlib.Path(p) for p in subprocess.check_output(['git', 'ls-files', '-z']).decode().split('\0') if p]
errors = []
for p in tracked:
    if p.is_symlink(): errors.append(f'symlink: {p}')
for p in root.rglob('*'):
    if '.git' in p.parts or not p.is_file(): continue
    if p.stat().st_size > 5_000_000: errors.append(f'over 5 MB: {p}')
    if p.name.endswith('.part') or p.name in ('.DS_Store',) or '__pycache__' in p.parts or '.cache' in p.parts:
        errors.append(f'cache/partial artifact: {p}')
    if p.suffix.lower() in ('.js', '.qml') and b'\r' in p.read_bytes(): errors.append(f'non-LF JS/QML: {p}')
m = json.loads(pathlib.Path('manifest.json').read_text())
c = pathlib.Path('CHANGELOG.md').read_text()
if m.get('id') != 'io.github.julianbruno.jezz-atelier' or not re.fullmatch(r'\d+\.\d+\.\d+', m.get('version', '')):
    errors.append('manifest id/version invalid')
if not re.search(r'^## \[' + re.escape(m.get('version', '')) + r'\] - (YYYY-MM-DD|\d{4}-\d{2}-\d{2})$', c, re.M):
    errors.append('changelog top release/version mismatch')
for error in errors: print(error)
if errors: raise SystemExit(1)
print('Repository hygiene OK')
PY
