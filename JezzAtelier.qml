import QtQuick
import Quickshell
import Quickshell.Wayland
import "components"

Item {
  id: root
  property var shell: null
  property var manifest: null
  property bool opened: false
  property bool reducedMotion: false

  function open(payloadJson) {
    root.opened = true
    view.restoreFocus()
  }
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
    color: "#101b17"
    WlrLayershell.namespace: "jezz-atelier"
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
    exclusionMode: ExclusionMode.Ignore

    GameView {
      id: view
      anchors.fill: parent
      opened: root.opened
      reducedMotion: root.reducedMotion
      onDismissRequested: root.dismiss()
    }
  }
}
