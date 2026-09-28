import QtQuick

// One claimed region of the board: the sharp painting, clipped to the region, fading in
// over the blurred field. Board delegates are reused across regions, so the fade only
// restarts when this delegate starts showing another region or its region is claimed;
// the per-frame snapshot swap alone changes nothing.
Item {
  id: root

  property var region: ({ id: 0, claimed: false })
  property var rect: ({ x: 0, y: 0, width: 0, height: 0 })
  property var box: ({ x: 0, y: 0, width: 0, height: 0 })
  property url source
  property int duration: 2600
  // function(region) -> progress to show now (0 to 1), or -1 when unclaimed.
  property var progressFor: null
  property int shownId: 0
  property bool shownClaimed: false
  property real progress: 0

  function sync() {
    if (region.id === shownId && region.claimed === shownClaimed) return
    shownId = region.id
    shownClaimed = region.claimed
    reveal.stop()
    progress = progressFor ? Math.max(0, progressFor(region)) : (region.claimed ? 1 : 0)
    if (region.claimed && progress < 1) {
      reveal.duration = (1 - progress) * duration
      reveal.start()
    }
  }

  onRegionChanged: sync()
  Component.onCompleted: sync()

  visible: region.claimed && progress > 0
  opacity: progress * progress * (3 - 2 * progress)
  x: rect.x
  y: rect.y
  width: rect.width
  height: rect.height
  clip: true

  Image {
    x: root.box.x - root.x
    y: root.box.y - root.y
    width: root.box.width
    height: root.box.height
    source: root.source
    fillMode: Image.PreserveAspectCrop
    asynchronous: true
    sourceSize.width: Math.ceil(root.box.width)
    sourceSize.height: Math.ceil(root.box.height)
  }

  NumberAnimation {
    id: reveal
    target: root
    property: "progress"
    to: 1
  }
}
