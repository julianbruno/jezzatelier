import QtQuick
import Quickshell
import Quickshell.Wayland

Item {
  id: root
  property var shell: null
  property var manifest: null
  property bool opened: false

  function open(payloadJson) { root.opened = true }
  function close() { root.opened = false }
  function dismiss() {
    root.close()
    if (root.shell && typeof root.shell.hide === "function")
      root.shell.hide(root.manifest.id)
  }
  function toggle() {
    if (root.opened) root.dismiss()
    else root.open("{}")
  }

  PanelWindow {
    visible: root.opened
    anchors { top: true; bottom: true; left: true; right: true }
    color: "#101c19"
    WlrLayershell.namespace: "jezz-atelier"
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
    exclusionMode: ExclusionMode.Ignore

    Text {
      anchors.centerIn: parent
      color: "#f5eedb"
      text: "Jezz Atelier — gameplay coming soon (Esc to close)"
    }
    Item {
      anchors.fill: parent
      focus: true
      Keys.onEscapePressed: root.dismiss()
    }
  }
}
