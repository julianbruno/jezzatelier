import QtQuick
import QtQuick.Shapes
import "Theme.js" as Theme

// Placement cursor: a ring with two arrowheads pointing where the wall will grow.
Item {
  id: root

  property string orientation: "vertical"
  property bool valid: true
  property real size: 24

  readonly property color tone: valid ? Theme.focus : Theme.danger

  width: size
  height: size * 2.2
  rotation: orientation === "horizontal" ? 90 : 0

  Rectangle {
    anchors.centerIn: parent
    width: root.size * 0.62
    height: width
    radius: width / 2
    color: "transparent"
    border.color: root.tone
    border.width: Math.max(2, root.size * 0.09)
  }

  Shape {
    anchors.fill: parent
    preferredRendererType: Shape.CurveRenderer

    ShapePath {
      strokeWidth: -1
      fillColor: root.tone
      startX: root.width / 2
      startY: 0
      PathLine { x: root.width * 0.2; y: root.height * 0.2 }
      PathLine { x: root.width * 0.8; y: root.height * 0.2 }
      PathLine { x: root.width / 2; y: 0 }
    }

    ShapePath {
      strokeWidth: -1
      fillColor: root.tone
      startX: root.width / 2
      startY: root.height
      PathLine { x: root.width * 0.2; y: root.height * 0.8 }
      PathLine { x: root.width * 0.8; y: root.height * 0.8 }
      PathLine { x: root.width / 2; y: root.height }
    }
  }
}
