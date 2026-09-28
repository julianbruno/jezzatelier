#!/usr/bin/env bash
# Optional desktop launcher. Operates only in stable, user-controlled XDG directories.
# Shell path checks cannot defend against hostile concurrent directory replacement.
set -euo pipefail
cd "$(dirname "$0")/.."

id=$(jq -r '.id' manifest.json)
name=$(jq -r '.name' manifest.json)
data_home="${XDG_DATA_HOME:-$HOME/.local/share}"
[[ $data_home != *$'\n'* && $data_home != *$'\r'* ]] || { echo 'Launcher refused: newline or carriage return in XDG data path' >&2; exit 1; }
desktop_file="$data_home/applications/$id.desktop"
icon_file="$data_home/icons/hicolor/256x256/apps/$id.png"

refuse() { echo "Launcher refused: $*" >&2; exit 1; }
# Check every existing ancestor, including the data root. Do not traverse links.
check_parents() {
  local path=$1 part current=/
  path=${path%/*}
  [[ $path == /* ]] || refuse 'XDG_DATA_HOME must be absolute'
  IFS=/ read -ra parts <<<"$path"
  for part in "${parts[@]}"; do
    [[ -z $part ]] && continue
    [[ $part != . && $part != .. ]] || refuse 'dot path component'
    current="${current%/}/$part"
    [[ ! -L $current ]] || refuse "symlink parent: $current"
    [[ ! -e $current || -d $current ]] || refuse "non-directory parent: $current"
  done
}
regular_single() {
  [[ ! -L $1 && -f $1 && $(stat -c %h -- "$1") == 1 ]]
}
identity() {
  printf '%s %s %s\n' "$(stat -c '%d:%i' -- "$1")" "$(sha256sum -- "$1" | cut -d' ' -f1)" "$(stat -c %s -- "$1")"
}
# A sidecar binds the installed bytes to the original device/inode and digest.
# Never trust a sidecar alone: verify both it and its target before removal.
owned() {
  local target=$1 state="$1.jezz-atelier-owner" recorded
  regular_single "$target" && regular_single "$state" || return 1
  recorded=$(<"$state")
  [[ $recorded == "jezz-atelier-v1 $(identity "$target")" ]] || return 1
  if [[ $target == "$desktop_file" ]]; then
    cmp -s -- "$target" <(printf '%s\n' "$entry")
  else
    cmp -s -- "$target" launcher/icon.png
  fi
}
check_pair() {
  local target=$1 state="$1.jezz-atelier-owner"
  check_parents "$target"
  [[ ! -L $target && ! -L $state ]] || refuse "symlink target or state: $target"
  if [[ -e $target || -e $state ]]; then
    [[ -e $target && -e $state ]] && owned "$target" || refuse "unowned or modified target: $target"
  fi
}
refresh_icon_cache() {
  if command -v gtk-update-icon-cache >/dev/null 2>&1; then
    gtk-update-icon-cache --quiet "$data_home/icons/hicolor" >/dev/null 2>&1 || true
  fi
}

case "${1:-}" in
  ''|--remove) ;;
  *) echo 'Usage: scripts/install-launcher.sh [--remove]' >&2; exit 1 ;;
esac
# Build the expected bytes before preflight, including on removal. A sidecar
# alone is not proof that arbitrary content belongs to this plugin.
entry=$(cat <<EOF
[Desktop Entry]
Type=Application
Version=1.0
Name=$name
GenericName=Arcade game
Comment=$(jq -r '.description' manifest.json)
Exec=omarchy-shell shell summon $id {}
Icon=$id
Terminal=false
Categories=Game;ArcadeGame;
Keywords=jezzball;game;painting;gallery;
EOF
)
check_pair "$desktop_file"
check_pair "$icon_file"
if [[ ${1:-} == --remove ]]; then
  for target in "$desktop_file" "$icon_file"; do
    if [[ -e $target ]]; then
      check_pair "$target"
      rm -- "$target"
      rm -- "$target.jezz-atelier-owner"
    fi
  done
  refresh_icon_cache
  echo "Removed $name from the app launcher."
  exit 0
fi

# Existing entries already passed identity and exact-content checks above.
# mkdir -p is limited to ancestors already checked above; recheck after creation.
mkdir -p -- "${desktop_file%/*}" "${icon_file%/*}"
check_pair "$desktop_file"
check_pair "$icon_file"
install_new() {
  local target=$1 source=$2 state="$1.jezz-atelier-owner"
  [[ ! -e $target && ! -L $target && ! -e $state && ! -L $state ]] || refuse "destination appeared: $target"
  # noclobber ensures a newly appearing leaf is not overwritten. Ownership is
  # recorded after the bytes are written; a failed sidecar leaves an unowned file
  # that must be inspected manually rather than guessed at on the next run.
  (set -C; printf '%s' "$source" >"$target") || refuse "cannot create $target"
  chmod 644 -- "$target"
  (set -C; printf 'jezz-atelier-v1 %s\n' "$(identity "$target")" >"$state") || refuse "cannot record ownership: $target"
}
if [[ ! -e $icon_file ]]; then
  # Binary input cannot be stored safely in a shell variable. Use a noclobber
  # output descriptor and copy into it rather than install(1)'s overwrite mode.
  (set -C; cat -- launcher/icon.png >"$icon_file") || refuse "cannot create $icon_file"
  chmod 644 -- "$icon_file"
  (set -C; printf 'jezz-atelier-v1 %s\n' "$(identity "$icon_file")" >"$icon_file.jezz-atelier-owner") || refuse 'cannot record icon ownership'
fi
[[ -e $desktop_file ]] || install_new "$desktop_file" "$entry"$'\n'
refresh_icon_cache
echo "Added $name to the app launcher: $desktop_file"
if ! omarchy-plugin-list --json 2>/dev/null | jq -e --arg id "$id" 'any(.[]; .id == $id and .enabled)' >/dev/null; then
  echo "Note: the plugin is not enabled yet; run: omarchy plugin enable $id" >&2
fi
