import QtQuick
import "../components"

Window {
  id: window
  width: 1600
  height: 1000
  visible: true
  color: "#101b17"

  GameView {
    id: view
    anchors.fill: parent
    opened: false // Drive fixed simulation steps ourselves; no asynchronous timer.
    menuVisible: false
  }

  function capture() {
    window.contentItem.grabToImage(function(result) {
      if (!result.saveToFile("preview.png")) console.error("Preview save failed")
      Qt.quit()
    }, Qt.size(1600, 1000))
  }

  Component.onCompleted: Qt.callLater(function() {
    view.controller.newGame("classic", 7)
    view.controller.start()
    // Alternate cut orientations so the preview shows both kinds of wall.
    var positions = [[4, 5, "vertical"], [11, 6, "horizontal"], [11, 5, "vertical"], [8, 2, "horizontal"],
      [8, 8, "horizontal"], [14, 8, "vertical"]]
    for (var p = 0; p < positions.length && view.controller.snapshot.coverage < 0.4; ++p) {
      if (view.controller.snapshot.orientation !== positions[p][2]) view.controller.toggleOrientation()
      view.controller.placeAt(positions[p][0], positions[p][1])
      for (var i = 0; i < 180 && view.controller.snapshot.status === "running"; ++i)
        view.controller.advance(1 / 60)
    }
    if (view.controller.snapshot.coverage === 0) console.warn("No claimed region in scripted preview")
    captureDelay.start()
  })

  Timer {
    id: captureDelay
    interval: 1200
    onTriggered: window.capture()
  }
}
