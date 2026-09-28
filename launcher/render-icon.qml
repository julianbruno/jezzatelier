import QtQuick
import "../components"
import "../components/Theme.js" as Theme

// App icon: a rounded board where one claimed region shows the painting of the first
// wave, split by gold walls, with two lacquered spheres in the open space. The offscreen
// window has no alpha channel, so render-icon.sh cuts the rounded corners afterwards.
Window {
  id: window
  width: 256
  height: 256
  visible: true
  color: Theme.ink

  Rectangle {
    id: tile
    x: 8
    y: 8
    width: 240
    height: 240
    radius: 52
    color: Theme.ink
    clip: true

    Item {
      id: claimed
      x: 6
      y: 6
      width: 104
      height: 228
      clip: true

      Image {
        x: -40
        width: 340
        height: 228
        source: "../assets/artworks/rubens-rainbow.jpg"
        fillMode: Image.PreserveAspectCrop
      }
    }

    Rectangle { x: 108; y: 0; width: 10; height: 240; color: Theme.wall }
    Rectangle { x: 118; y: 128; width: 122; height: 10; color: Theme.wall }

    Sphere { x: 146; y: 44; width: 58; height: 58; tint: Theme.sphereTint(1) }
    Sphere { x: 170; y: 162; width: 44; height: 44; tint: Theme.sphereTint(3) }

    // Drawn last so it covers the painting where it meets the rounded corners.
    Rectangle {
      anchors.fill: parent
      radius: parent.radius
      color: "transparent"
      border.color: Theme.gold
      border.width: 6
    }
  }

  Component.onCompleted: Qt.callLater(function() {
    window.contentItem.grabToImage(function(result) {
      if (!result.saveToFile(outputPath)) console.error("Icon save failed")
      Qt.quit()
    }, Qt.size(256, 256))
  })

  readonly property string outputPath: Qt.application.arguments[Qt.application.arguments.length - 1]
}
