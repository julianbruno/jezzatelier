#!/usr/bin/env bash
# Adds Jezz Atelier to the Omarchy app launcher as a regular desktop app, or removes it
# with --remove. Omarchy plugins have no install hooks, so this is a separate, opt-in step.
# It writes one desktop entry and one icon under ~/.local/share; nothing else.
#
# Usage: scripts/install-launcher.sh [--remove]
set -euo pipefail
cd "$(dirname "$0")/.."

id=$(jq -r '.id' manifest.json)
name=$(jq -r '.name' manifest.json)
data_home="${XDG_DATA_HOME:-$HOME/.local/share}"
desktop_file="$data_home/applications/$id.desktop"
icon_file="$data_home/icons/hicolor/256x256/apps/$id.png"

refresh_icon_cache() {
  if command -v gtk-update-icon-cache >/dev/null 2>&1; then
    gtk-update-icon-cache --quiet "$data_home/icons/hicolor" >/dev/null 2>&1 || true
  fi
}

case "${1:-}" in
  --remove)
    rm -f "$desktop_file" "$icon_file"
    refresh_icon_cache
    echo "Removed $name from the app launcher."
    exit 0
    ;;
  "") ;;
  *)
    echo "Usage: scripts/install-launcher.sh [--remove]" >&2
    exit 1
    ;;
esac

mkdir -p "$(dirname "$desktop_file")" "$(dirname "$icon_file")"
install -m 644 launcher/icon.png "$icon_file"
refresh_icon_cache

cat >"$desktop_file" <<EOF
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

echo "Added $name to the app launcher: $desktop_file"
if ! omarchy-plugin-list --json 2>/dev/null | jq -e --arg id "$id" 'any(.[]; .id == $id and .enabled)' >/dev/null; then
  echo "Note: the plugin is not enabled yet; run: omarchy plugin enable $id" >&2
fi
