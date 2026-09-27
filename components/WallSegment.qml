import QtQuick
import "../engine/Layout.js" as Layout

// A wall drawn from world coordinates: centered on `fixed`, spanning `from`..`to`.
Rectangle {
  property var box: ({ x: 0, y: 0, width: 0, height: 0 })
  property string orientation: "vertical"
  property real fixed: 0
  property real from: 0
  property real to: 0
  property real thickness: 0.08

  readonly property var rect: Layout.segmentRect(box, orientation, fixed, from, to, thickness)

  x: rect.x
  y: rect.y
  width: rect.width
  height: rect.height
}
