import QtQuick
import Quickshell
import Quickshell.Io
import "../engine/Storage.js" as Storage

Item {
  id: root
  property var preferences: Storage.defaultPreferences()
  property var highScores: []
  property bool loaded: false
  readonly property string statePath: (Quickshell.env("XDG_STATE_HOME")
    || Quickshell.env("HOME") + "/.local/state") + "/jezz-atelier/state.json"

  function save() {
    if (!loaded) return
    debounce.stop()
    file.setText(Storage.serializeState({ preferences: preferences, highScores: highScores }))
  }

  function scheduleSave() {
    if (loaded) debounce.restart()
  }

  onPreferencesChanged: scheduleSave()
  onHighScoresChanged: scheduleSave()

  Timer {
    id: debounce
    interval: 500
    onTriggered: root.save()
  }

  FileView {
    id: file
    path: root.statePath
    atomicWrites: true
    printErrors: false
    onLoaded: {
      var state = Storage.parseState(text())
      root.preferences = state.preferences
      root.highScores = state.highScores
      root.loaded = true
    }
    onLoadFailed: {
      root.loaded = true
    }
  }
}
