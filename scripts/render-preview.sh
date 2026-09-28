#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
# The default offscreen renderer is software and cannot run MultiEffect; use OpenGL.
QT_QPA_PLATFORM=offscreen QT_QUICK_BACKEND=rhi QSG_RHI_BACKEND=opengl /usr/lib/qt6/bin/qml -I . scripts/render-preview.qml
magick preview.png -strip -dither None -colors 256 -define png:compression-level=9 PNG8:preview.png
bytes=$(stat -c %s preview.png)
(( bytes < 800000 )) || { echo "Preview too large: $bytes bytes" >&2; exit 1; }
magick identify -format 'Preview: %wx%h, %b\n' preview.png
