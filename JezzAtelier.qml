import QtQuick
import Quickshell
import Quickshell.Wayland
import "components"

// Omarchy overlay entry point. Owns the host lifecycle, the layer-shell window, local
// state persistence, and the optional audio director; gameplay lives in GameView.
Item {
  id: root

  property var shell: null
  property var manifest: null
  property bool opened: false

  function open(payloadJson) {
    root.opened = true
    view.restoreFocus()
  }

  function close() {
    stateFile.save()
    root.opened = false
  }

  function dismiss() {
    root.close()
    if (root.shell && typeof root.shell.hide === "function")
      root.shell.hide(root.manifest.id)
  }

  function toggle() {
    if (root.opened) root.dismiss()
    else root.open("{}")
  }

  StateFile {
    id: stateFile
  }

  // Loaded by URL so a system without QtMultimedia still gets a working, silent game.
  Loader {
    id: audio
    active: root.opened
    source: "components/AudioDirector.qml"

    onLoaded: {
      item.shouldPlay = Qt.binding(function() { return view.musicShouldPlay })
      item.wave = Qt.binding(function() { return view.controller.snapshot.wave })
      item.musicVolume = Qt.binding(function() { return view.preferences.musicVolume })
      item.sfxVolume = Qt.binding(function() { return view.preferences.sfxVolume })
      item.events = view
    }
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
      preferences: stateFile.preferences
      highScores: stateFile.highScores
      onPersistenceRequested: {
        stateFile.preferences = preferences
        stateFile.highScores = highScores
      }
      onDismissRequested: root.dismiss()
    }
  }
}
