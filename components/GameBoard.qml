pragma ComponentBehavior: Bound
import QtQuick
import "../engine/Layout.js" as Layout
import "../engine/Collection.js" as Collection

// Renders one engine snapshot inside a letterboxed 16:10 field and reports pointer input
// in world coordinates.
Item {
  id: root

  property var snapshot: null
  property var preview: null
  property bool randomArtwork: true
  property string artworkId: Collection.artworks[0].id
  property int brightness: 82
  property real cursorX: 8
  property real cursorY: 5

  readonly property var artwork: Collection.artworkForWave(snapshot ? snapshot.wave : 1, randomArtwork, artworkId)
  readonly property url artworkSource: Qt.resolvedUrl("../" + artwork.file)
  // Unclaimed field stays veiled so claiming visibly uncovers the painting;
  // brightness 100 keeps a light veil, 45 a heavy one.
  readonly property real veilOpacity: 0.3 + (100 - brightness) / 55 * 0.45

  readonly property var box: Layout.fit(width, height)
  readonly property real unit: box.width / 16
  readonly property var growingWall: snapshot ? snapshot.growingWall : null
  readonly property int claimedCount: snapshot
    ? snapshot.regions.filter(function(region) { return region.claimed }).length
    : 0

  signal hovered(real x, real y)
  signal placed(real x, real y)
  signal rotated()

  function clampedWorld(pixelX, pixelY) {
    var point = Layout.toWorld(box, pixelX, pixelY)
    return { x: Math.max(0.1, Math.min(15.9, point.x)), y: Math.max(0.1, Math.min(9.9, point.y)) }
  }

  function insideBox(pixelX, pixelY) {
    return pixelX >= box.x && pixelX <= box.x + box.width
      && pixelY >= box.y && pixelY <= box.y + box.height
  }

  Item {
    x: root.box.x
    y: root.box.y
    width: root.box.width
    height: root.box.height
    clip: true

    Image {
      anchors.fill: parent
      source: root.artworkSource
      fillMode: Image.PreserveAspectCrop
      asynchronous: true
      sourceSize.width: Math.ceil(parent.width)
      sourceSize.height: Math.ceil(parent.height)
    }

    Rectangle {
      anchors.fill: parent
      color: "#101b17"
      opacity: root.veilOpacity
    }
  }

  Repeater {
    model: root.snapshot ? root.snapshot.regions : []

    Item {
      required property var modelData
      readonly property var topLeft: Layout.toPixel(root.box, modelData.minX, modelData.minY)
      readonly property var bottomRight: Layout.toPixel(root.box, modelData.maxX, modelData.maxY)

      visible: modelData.claimed
      x: topLeft.x
      y: topLeft.y
      width: bottomRight.x - topLeft.x
      height: bottomRight.y - topLeft.y
      clip: true
      Image {
        x: root.box.x - parent.x
        y: root.box.y - parent.y
        width: root.box.width
        height: root.box.height
        source: root.artworkSource
        fillMode: Image.PreserveAspectCrop
        asynchronous: true
        sourceSize.width: Math.ceil(root.box.width)
        sourceSize.height: Math.ceil(root.box.height)
      }
      Rectangle {
        anchors.fill: parent
        color: "transparent"
        border.color: "#d7b979"
        border.width: Math.max(1, root.unit * 0.025)
      }
    }
  }

  Rectangle {
    x: root.box.x
    y: root.box.y
    width: root.box.width
    height: root.box.height
    color: "transparent"
    border.color: "#c8ad72"
    border.width: Math.max(2, root.unit * 0.04)
  }

  Repeater {
    model: root.snapshot ? root.snapshot.walls : []

    WallSegment {
      required property var modelData
      box: root.box
      orientation: modelData.orientation
      fixed: modelData.orientation === "vertical" ? modelData.x : modelData.y
      from: modelData.negativeLimit
      to: modelData.positiveLimit
      color: "#e6c584"
    }
  }

  WallSegment {
    visible: root.growingWall !== null
    box: root.box
    orientation: root.growingWall ? root.growingWall.orientation : "vertical"
    fixed: root.growingWall ? (orientation === "vertical" ? root.growingWall.x : root.growingWall.y) : 0
    from: root.growingWall ? root.growingWall.negativeEnd : 0
    to: root.growingWall ? root.growingWall.positiveEnd : 0
    thickness: 0.1
    color: "#6de3e5"
  }

  Repeater {
    model: root.snapshot ? root.snapshot.spheres : []

    Rectangle {
      required property var modelData
      readonly property var center: Layout.toPixel(root.box, modelData.x, modelData.y)

      width: modelData.radius * 2 * root.unit
      height: width
      x: center.x - width / 2
      y: center.y - height / 2
      radius: width / 2
      color: "#f4e9d1"
      border.color: "#b59757"
    }
  }

  WallSegment {
    visible: root.preview !== null && root.preview.regionId !== null
    box: root.box
    orientation: root.preview ? root.preview.orientation : "vertical"
    fixed: root.preview ? (orientation === "vertical" ? root.preview.x : root.preview.y) : 0
    from: root.preview && root.preview.regionId !== null ? root.preview.negativeLimit : 0
    to: root.preview && root.preview.regionId !== null ? root.preview.positiveLimit : 0
    thickness: 0.05
    color: root.preview && root.preview.valid ? "#6de3e5" : "#ec827d"
    opacity: 0.75
  }

  Rectangle {
    readonly property var center: Layout.toPixel(root.box, root.cursorX, root.cursorY)

    width: Math.max(12, root.unit * 0.3)
    height: width
    x: center.x - width / 2
    y: center.y - height / 2
    radius: width / 2
    color: "transparent"
    border.color: "#6de3e5"
    border.width: 2
  }

  MouseArea {
    anchors.fill: parent
    hoverEnabled: true
    acceptedButtons: Qt.LeftButton | Qt.RightButton

    onPositionChanged: function(mouse) {
      var point = root.clampedWorld(mouse.x, mouse.y)
      root.hovered(point.x, point.y)
    }

    onClicked: function(mouse) {
      if (mouse.button === Qt.RightButton) {
        root.rotated()
      } else if (root.insideBox(mouse.x, mouse.y)) {
        var point = Layout.toWorld(root.box, mouse.x, mouse.y)
        root.placed(point.x, point.y)
      }
    }
  }
}
