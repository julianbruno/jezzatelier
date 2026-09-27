import QtQuick
import "Theme.js" as Theme

// Thin horizontal gauge with an optional target marker (for the coverage goal).
Rectangle {
  id: root

  property real fraction: 0
  property real target: -1
  property color fill: Theme.goldBright

  implicitWidth: 150
  implicitHeight: 6
  radius: height / 2
  color: "#0b1411"
  border.color: "#2f4239"

  Rectangle {
    width: Math.max(0, Math.min(1, root.fraction)) * root.width
    height: root.height
    radius: root.radius
    color: root.fill
  }

  Rectangle {
    visible: root.target >= 0
    x: root.target * root.width - width / 2
    y: -3
    width: 2
    height: root.height + 6
    color: Theme.ivory
  }
}
