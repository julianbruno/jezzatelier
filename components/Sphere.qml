import QtQuick
import QtQuick.Shapes

// A lacquered sphere seen from above: soft contact shadow, radial body shading,
// dark rim, and a clear-coat highlight toward the upper-left light.
Item {
  id: root

  property color tint: "#e67049"

  implicitWidth: 24
  implicitHeight: 24

  Rectangle {
    x: root.width * 0.12
    y: root.height * 0.16
    width: root.width
    height: root.height
    radius: width / 2
    color: "#020705"
    opacity: 0.38
  }

  Shape {
    anchors.fill: parent
    preferredRendererType: Shape.CurveRenderer

    ShapePath {
      strokeColor: Qt.darker(root.tint, 1.9)
      strokeWidth: Math.max(1, root.width * 0.04)
      fillGradient: RadialGradient {
        centerX: root.width * 0.36
        centerY: root.height * 0.32
        centerRadius: root.width * 0.78
        focalX: centerX
        focalY: centerY

        GradientStop { position: 0; color: Qt.lighter(root.tint, 1.45) }
        GradientStop { position: 0.45; color: root.tint }
        GradientStop { position: 1; color: Qt.darker(root.tint, 2.2) }
      }

      PathAngleArc {
        centerX: root.width / 2
        centerY: root.height / 2
        radiusX: root.width / 2
        radiusY: root.height / 2
        startAngle: 0
        sweepAngle: 360
      }
    }
  }

  Rectangle {
    x: root.width * 0.2
    y: root.height * 0.14
    width: root.width * 0.34
    height: root.height * 0.2
    radius: height / 2
    rotation: -32
    color: "#ffffff"
    opacity: 0.72
  }
}
