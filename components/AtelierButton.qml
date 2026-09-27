import QtQuick

Rectangle {
  id: root
  property string label: ""
  signal activated()
  implicitWidth: Math.max(140, caption.implicitWidth + 32)
  implicitHeight: 44
  radius: 4
  color: mouse.containsMouse || activeFocus ? "#31463d" : "#1c2c25"
  border.color: activeFocus ? "#6de3e5" : "#c8ad72"
  border.width: activeFocus ? 3 : 1
  activeFocusOnTab: true
  Text {
    id: caption
    anchors.centerIn: parent
    text: root.label
    color: "#f5eedb"
    font.pixelSize: 14
    font.bold: true
  }
  MouseArea {
    id: mouse
    anchors.fill: parent
    hoverEnabled: true
    onClicked: { root.forceActiveFocus(); root.activated() }
  }
  Keys.onReturnPressed: activated()
  Keys.onEnterPressed: activated()
  Keys.onSpacePressed: activated()
}
