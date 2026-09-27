import QtQuick
import "Theme.js" as Theme

Rectangle {
  id: root

  property string label: ""
  property bool selected: false
  // The one main action of a screen: filled gold with dark text.
  property bool primary: false

  signal activated()

  implicitWidth: Math.max(140, caption.implicitWidth + 32)
  implicitHeight: 44
  radius: 4
  color: primary
    ? (mouse.containsMouse || activeFocus ? Theme.wall : Theme.goldBright)
    : (selected ? Theme.controlSelected : (mouse.containsMouse || activeFocus ? Theme.controlHover : Theme.control))
  border.color: activeFocus ? Theme.focus : Theme.gold
  border.width: activeFocus ? 3 : 1
  activeFocusOnTab: true

  Keys.onReturnPressed: activated()
  Keys.onEnterPressed: activated()
  Keys.onSpacePressed: activated()

  Text {
    id: caption
    anchors.centerIn: parent
    text: root.label
    color: root.primary ? Theme.ink : Theme.ivory
    font.pixelSize: root.primary ? 15 : 14
    font.bold: true
    font.letterSpacing: 0.6
  }

  MouseArea {
    id: mouse
    anchors.fill: parent
    hoverEnabled: true
    onClicked: {
      root.forceActiveFocus()
      root.activated()
    }
  }
}
