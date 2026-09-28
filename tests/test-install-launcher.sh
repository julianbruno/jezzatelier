#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
script="$PWD/scripts/install-launcher.sh"
id=$(jq -r .id manifest.json)
root=$(mktemp -d)
trap 'rm -rf "$root"' EXIT
export XDG_DATA_HOME="$root/data"
export HOME="$root/home"
mkdir -p "$HOME"
export PATH="$root/bin:$PATH"
mkdir -p "$root/bin"
printf '#!/bin/sh\nexit 0\n' >"$root/bin/omarchy-plugin-list"
chmod +x "$root/bin/omarchy-plugin-list"
desktop="$XDG_DATA_HOME/applications/$id.desktop"
icon="$XDG_DATA_HOME/icons/hicolor/256x256/apps/$id.png"
fail() { echo "FAIL: $*" >&2; exit 1; }
refuses() { if "$script" "$@" >"$root/output" 2>&1; then fail "accepted unsafe operation $*"; fi; }
"$script"
[[ -f "$desktop" && -f "$icon" ]] || fail 'initial installation'
"$script"
"$script" --remove
[[ ! -e "$desktop" && ! -e "$icon" ]] || fail 'owned removal'
mkdir -p "$(dirname "$desktop")" "$(dirname "$icon")"
printf 'external' >"$desktop"
refuses
[[ $(<"$desktop") == external && ! -e "$icon" ]] || fail 'conflicting desktop changed'
refuses --remove
[[ $(<"$desktop") == external ]] || fail 'unowned desktop removed'
rm "$desktop"
printf 'external' >"$icon"
refuses
[[ $(<"$icon") == external ]] || fail 'conflicting icon changed'
rm "$icon"
printf 'external' >"$root/sentinel"
ln -s "$root/sentinel" "$desktop"
refuses
refuses --remove
[[ $(<"$root/sentinel") == external ]] || fail 'leaf symlink followed'
rm "$desktop"
ln "$root/sentinel" "$icon"
refuses
refuses --remove
[[ $(<"$root/sentinel") == external ]] || fail 'hard link touched'
rm "$icon"
# Parent links must not be traversed even for absent leaves.
rmdir "$XDG_DATA_HOME/applications"
ln -s "$root" "$XDG_DATA_HOME/applications"
refuses
refuses --remove
[[ $(<"$root/sentinel") == external ]] || fail 'parent symlink followed'
rm "$XDG_DATA_HOME/applications"
"$script"
printf '\nmodified\n' >>"$desktop"
refuses
refuses --remove
[[ -f "$desktop" && -f "$icon" ]] || fail 'modified owned file removed'
# An ownership marker must not authorize removal of a newly substituted inode.
rm "$desktop"
printf 'substitute' >"$desktop"
refuses --remove
[[ $(<"$desktop") == substitute ]] || fail 'substituted file removed'
# Forged metadata must not authorize an unrelated regular desktop entry.
if [[ ${LAUNCHER_CASE:-all} == forged || ${LAUNCHER_CASE:-all} == all ]]; then
  rm "$desktop" "$desktop.jezz-atelier-owner" "$icon" "$icon.jezz-atelier-owner"
  printf 'unrelated' >"$desktop"
  printf 'jezz-atelier-v1 %s %s %s\n' "$(stat -c '%d:%i' "$desktop")" "$(sha256sum "$desktop" | cut -d' ' -f1)" "$(stat -c %s "$desktop")" >"$desktop.jezz-atelier-owner"
  refuses --remove
  [[ $(<"$desktop") == unrelated ]] || fail 'forged sidecar deleted unrelated entry'
  rm "$desktop" "$desktop.jezz-atelier-owner"
fi
# A newline must not truncate parent component validation before a symlink.
if [[ ${LAUNCHER_CASE:-all} == newline || ${LAUNCHER_CASE:-all} == all ]]; then
  export XDG_DATA_HOME="$root/new"$'\n'"line/data"
  mkdir -p "$root/new"$'\n'"line" "$root/outside"
  ln -s "$root/outside" "$root/new"$'\n'"line/data"
  refuses
  [[ ! -e "$root/outside/applications/$id.desktop" && ! -e "$root/outside/icons/hicolor/256x256/apps/$id.png" ]] || fail 'newline path traversed symlink'
fi
# Dangling leaf and sidecar links are conflicts even though -e is false.
export XDG_DATA_HOME="$root/data"
rm -f "$desktop" "$desktop.jezz-atelier-owner" "$icon" "$icon.jezz-atelier-owner"
ln -s "$root/missing" "$desktop"
refuses
refuses --remove
rm "$desktop"
ln -s "$root/missing" "$icon.jezz-atelier-owner"
refuses
refuses --remove
rm "$icon.jezz-atelier-owner"
printf 'orphan' >"$desktop.jezz-atelier-owner"
refuses
refuses --remove
[[ $(<"$desktop.jezz-atelier-owner") == orphan ]] || fail 'orphan state removed'
rm "$desktop.jezz-atelier-owner"
# Reject symlinks in the icon path, not just the applications path.
rmdir "$XDG_DATA_HOME/icons/hicolor/256x256/apps"
ln -s "$root/outside" "$XDG_DATA_HOME/icons/hicolor/256x256/apps"
refuses
refuses --remove
[[ ! -e "$root/outside/$id.png" ]] || fail 'icon parent symlink followed'
echo 'Launcher safety tests OK'
