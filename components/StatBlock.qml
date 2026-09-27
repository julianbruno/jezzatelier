import QtQuick
import "Theme.js" as Theme

// A HUD cell: small uppercase caption above a prominent value, with optional content
// (bars, dots) placed below through the default property.
Column {
  id: root

  property string caption: ""
  property string value: ""
  property color valueColor: Theme.ivory
  default property alias extra: extras.data

  spacing: 3

  Text {
    text: root.caption
    color: Theme.gold
    font.pixelSize: 11
    font.bold: true
    font.letterSpacing: 1.2
  }

  Text {
    visible: root.value.length > 0
    text: root.value
    color: root.valueColor
    font.pixelSize: 20
    font.bold: true
  }

  Item {
    id: extras
    width: childrenRect.width
    height: childrenRect.height
  }
}
