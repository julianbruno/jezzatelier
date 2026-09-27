import QtQuick
import "../engine/Engine.js" as Engine

// Owns the engine state and publishes JSON snapshots for rendering. Per-frame work
// runs only while the overlay is open and the game is running.
Item {
  id: root

  property bool opened: false
  property var gameState: Engine.createGame(1, {})
  property var snapshot: Engine.snapshot(gameState)
  property int revision: 0
  property var clock: ({ remainder: 0 })
  // A stalled frame (compositor hitch, suspend) must not drain the player's clock.
  readonly property real maxFrameTime: 0.25
  readonly property bool frameActive: opened && snapshot.status === "running"

  visible: false

  onOpenedChanged: {
    if (!opened && gameState.status === "running") togglePause()
  }

  function publish() {
    snapshot = Engine.snapshot(gameState)
    revision++
  }

  function resetClock() {
    clock = { remainder: 0 }
  }

  function newGame(difficulty, playerCount, seed) {
    var options = { difficulty: difficulty, playerCount: playerCount }
    gameState = Engine.createGame(seed === undefined ? Date.now() : seed, options)
    resetClock()
    publish()
  }

  function start() {
    Engine.start(gameState)
    publish()
  }

  function togglePause() {
    Engine.togglePause(gameState)
    resetClock()
    publish()
  }

  function toggleOrientation() {
    Engine.toggleOrientation(gameState)
    publish()
  }

  function placeAt(x, y) {
    var placed = Engine.placeWall(gameState, x, y)
    publish()
    return placed
  }

  function previewAt(x, y) {
    return Engine.previewWall(gameState, x, y)
  }

  function nextWave() {
    var advanced = Engine.nextLevel(gameState)
    if (advanced) {
      resetClock()
      publish()
    }
    return advanced
  }

  function backToMenu() {
    if (gameState.status === "running") Engine.togglePause(gameState)
    publish()
  }

  function advance(frameTime) {
    Engine.advanceFrame(gameState, clock, Math.min(maxFrameTime, frameTime))
    publish()
  }

  FrameAnimation {
    running: root.frameActive
    onTriggered: root.advance(frameTime)
  }
}
