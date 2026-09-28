pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Effects
import "Theme.js" as Theme
import "../engine/Layout.js" as Layout
import "../engine/Collection.js" as Collection

// Renders one engine snapshot inside a letterboxed 16:10 field and reports pointer input
// in world coordinates. Repeaters are driven by counts, not by the snapshot arrays, so
// delegates survive the per-frame snapshot swap and only their bindings update.
Item {
  id: root

  property var snapshot: null
  property var preview: null
  property bool randomArtwork: true
  property string artworkId: Collection.artworks[0].id
  property int brightness: 82
  property bool reducedMotion: false
  property bool interactive: false
  property real cursorX: 8
  property real cursorY: 5
  property real wheelTravel: 0
  // Claimed regions bring the sharp painting into focus over this many milliseconds.
  property int revealDuration: 2600
  // When each claimed region of the current field started its reveal, by region id.
  // Keyed by id, not delegate, because a split shifts regions between delegates.
  property var revealStarts: ({})

  readonly property var artwork: Collection.artworkForWave(snapshot ? snapshot.wave : 1, randomArtwork, artworkId)
  readonly property url artworkSource: Qt.resolvedUrl("../" + artwork.file)
  // Unclaimed field shows a blurred, grainy, veiled painting so claiming visibly
  // uncovers it; brightness 100 keeps a light veil, 45 a heavy one.
  readonly property real veilOpacity: 0.3 + (100 - brightness) / 55 * 0.45
  readonly property var box: Layout.fit(width, height)
  readonly property real unit: box.width / 16
  readonly property var growingWall: snapshot ? snapshot.growingWall : null
  // Fallbacks for the instant a shrinking snapshot array outruns its Repeater's count.
  readonly property var emptyRegion: ({ id: 0, minX: 0, maxX: 0, minY: 0, maxY: 0, claimed: false })
  readonly property var emptyWall: ({ orientation: "vertical", x: 0, y: 0, negativeLimit: 0, positiveLimit: 0 })
  readonly property var emptySphere: ({ id: 1, x: 0, y: 0, radius: 0 })
  readonly property int claimedCount: snapshot
    ? snapshot.regions.filter(function(region) { return region.claimed }).length
    : 0

  // Every field starts with nothing claimed, and region ids restart with each field.
  onClaimedCountChanged: if (claimedCount === 0) revealStarts = ({})

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

  function regionRect(region) {
    var topLeft = Layout.toPixel(box, region.minX, region.minY)
    var bottomRight = Layout.toPixel(box, region.maxX, region.maxY)
    return { x: topLeft.x, y: topLeft.y, width: bottomRight.x - topLeft.x, height: bottomRight.y - topLeft.y }
  }

  // Briefly lights up newly claimed regions.
  function flashClaims(regions) {
    if (reducedMotion) return
    regions.forEach(function(region) { claimFlash.createObject(root, { rect: root.regionRect(region) }) })
  }

  // Touchpads report many small deltas; rotate once per full wheel notch (120).
  function handleWheel(deltaY) {
    wheelTravel += deltaY
    if (Math.abs(wheelTravel) < 120) return
    wheelTravel = 0
    rotated()
  }

  // Reveal progress (0 to 1) a claimed region should show now; -1 when unclaimed.
  function revealProgress(region) {
    if (!region.claimed) return -1
    if (reducedMotion) return 1
    var started = revealStarts[region.id]
    if (started === undefined) {
      started = Date.now()
      revealStarts[region.id] = started
    }
    return Math.min(1, (Date.now() - started) / Math.max(1, revealDuration))
  }

  // Progress of the region with this id, or -1 when it is not on the board.
  function revealOf(regionId) {
    for (var i = 0; i < regionViews.count; i++) {
      var view = regionViews.itemAt(i) as RegionReveal
      if (view && view.region.id === regionId) return view.progress
    }
    return -1
  }

  function flashLoss() {
    if (!reducedMotion) lossFlash.restart()
  }

  Item {
    x: root.box.x
    y: root.box.y
    width: root.box.width
    height: root.box.height
    clip: true

    // Loaded tiny and then blurred: cheap, and no detail survives to spoil the reveal.
    // It stays visible under the blur, so the software renderer, which cannot run
    // MultiEffect, still shows a soft painting instead of an empty field.
    Image {
      id: veiledArtwork
      anchors.fill: parent
      source: root.artworkSource
      fillMode: Image.PreserveAspectCrop
      asynchronous: true
      smooth: true
      sourceSize.width: 96
      sourceSize.height: 60
    }

    MultiEffect {
      anchors.fill: parent
      source: veiledArtwork
      blurEnabled: true
      blur: 1
      blurMax: 48
    }

    // Grain regenerated with:
    // magick -seed 7 -size 256x256 xc:gray50 -attenuate 1.6 +noise Gaussian -colorspace Gray -depth 8 grain.png
    Image {
      anchors.fill: parent
      source: "grain.png"
      fillMode: Image.Tile
      opacity: 0.4
    }

    Rectangle {
      anchors.fill: parent
      color: Theme.ink
      opacity: root.veilOpacity
    }
  }

  Repeater {
    id: regionViews
    model: root.snapshot ? root.snapshot.regions.length : 0

    RegionReveal {
      required property int index

      region: root.snapshot.regions[index] || root.emptyRegion
      rect: root.regionRect(region)
      box: root.box
      source: root.artworkSource
      duration: root.revealDuration
      progressFor: root.revealProgress
    }
  }

  Rectangle {
    x: root.box.x
    y: root.box.y
    width: root.box.width
    height: root.box.height
    color: "transparent"
    border.color: Theme.gold
    border.width: Math.max(2, root.unit * 0.05)
  }

  Repeater {
    model: root.snapshot ? root.snapshot.walls.length : 0

    WallSegment {
      required property int index
      readonly property var wall: root.snapshot.walls[index] || root.emptyWall

      box: root.box
      orientation: wall.orientation
      fixed: wall.orientation === "vertical" ? wall.x : wall.y
      from: wall.negativeLimit
      to: wall.positiveLimit
      thickness: 0.09
      color: Theme.wall
    }
  }

  WallSegment {
    visible: root.growingWall !== null
    box: root.box
    orientation: root.growingWall ? root.growingWall.orientation : "vertical"
    fixed: root.growingWall ? (orientation === "vertical" ? root.growingWall.x : root.growingWall.y) : 0
    from: root.growingWall ? root.growingWall.negativeEnd : 0
    to: root.growingWall ? root.growingWall.positiveEnd : 0
    thickness: 0.26
    color: Theme.focus
    opacity: 0.3
  }

  WallSegment {
    visible: root.growingWall !== null
    box: root.box
    orientation: root.growingWall ? root.growingWall.orientation : "vertical"
    fixed: root.growingWall ? (orientation === "vertical" ? root.growingWall.x : root.growingWall.y) : 0
    from: root.growingWall ? root.growingWall.negativeEnd : 0
    to: root.growingWall ? root.growingWall.positiveEnd : 0
    thickness: 0.11
    color: "#bff6f7"
  }

  WallSegment {
    visible: root.interactive && root.growingWall === null && root.preview !== null && root.preview.regionId !== null
    box: root.box
    orientation: root.preview ? root.preview.orientation : "vertical"
    fixed: root.preview ? (orientation === "vertical" ? root.preview.x : root.preview.y) : 0
    from: root.preview && root.preview.regionId !== null ? root.preview.negativeLimit : 0
    to: root.preview && root.preview.regionId !== null ? root.preview.positiveLimit : 0
    thickness: 0.05
    color: root.preview && root.preview.valid ? Theme.focus : Theme.danger
    opacity: 0.7
  }

  Repeater {
    model: root.snapshot ? root.snapshot.spheres.length : 0

    Sphere {
      required property int index
      readonly property var sphere: root.snapshot.spheres[index] || root.emptySphere
      readonly property var center: Layout.toPixel(root.box, sphere.x, sphere.y)

      width: sphere.radius * 2 * root.unit
      height: width
      x: center.x - width / 2
      y: center.y - height / 2
      tint: Theme.sphereTint(sphere.id)
    }
  }

  WallCursor {
    readonly property var center: Layout.toPixel(root.box, root.cursorX, root.cursorY)

    visible: root.interactive
    size: Math.max(18, root.unit * 0.42)
    x: center.x - width / 2
    y: center.y - height / 2
    orientation: root.snapshot && root.snapshot.orientation ? root.snapshot.orientation : "vertical"
    valid: root.preview !== null && root.preview.valid
  }

  Rectangle {
    id: lossBorder
    x: root.box.x
    y: root.box.y
    width: root.box.width
    height: root.box.height
    color: "transparent"
    border.color: Theme.danger
    border.width: Math.max(4, root.unit * 0.12)
    opacity: 0

    SequentialAnimation on opacity {
      id: lossFlash
      running: false
      NumberAnimation { to: 1; duration: 80 }
      NumberAnimation { to: 0; duration: 520; easing.type: Easing.OutCubic }
    }
  }

  Component {
    id: claimFlash

    Rectangle {
      id: flash

      property var rect: ({ x: 0, y: 0, width: 0, height: 0 })

      x: rect.x
      y: rect.y
      width: rect.width
      height: rect.height
      color: Theme.goldBright
      border.color: Theme.ivory
      border.width: 2

      SequentialAnimation on opacity {
        running: true
        NumberAnimation { from: 0.55; to: 0; duration: 650; easing.type: Easing.OutQuad }
        ScriptAction { script: flash.destroy() }
      }
    }
  }

  MouseArea {
    anchors.fill: parent
    hoverEnabled: true
    acceptedButtons: Qt.LeftButton | Qt.RightButton
    cursorShape: root.interactive && containsMouse && root.insideBox(mouseX, mouseY)
      ? Qt.BlankCursor
      : Qt.ArrowCursor

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

    onWheel: function(wheel) {
      root.handleWheel(wheel.angleDelta.y)
    }
  }
}
