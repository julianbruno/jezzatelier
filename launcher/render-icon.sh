#!/usr/bin/env bash
# Renders launcher/icon.png, the 256×256 app icon, from the game's own components.
set -euo pipefail
cd "$(dirname "$0")/.."
QT_QPA_PLATFORM=offscreen /usr/lib/qt6/bin/qml -I . launcher/render-icon.qml -- "$PWD/launcher/icon.png"
# Keep the tile and make everything outside its rounded outline transparent.
magick launcher/icon.png \
  \( -size 256x256 xc:black -fill white -draw "roundrectangle 8,8 247,247 52,52" \) \
  -alpha off -compose CopyOpacity -composite -strip launcher/icon.png
magick identify -format 'Icon: %wx%h, %b\n' launcher/icon.png
