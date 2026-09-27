import QtQuick
import QtTest
import "../components"
import "../engine/Engine.js" as Engine

TestCase {
  name: "View"
  Component { id: boardComponent; GameBoard { width: 640; height: 400 } }
  Component { id: hudComponent; GameHud {} }
  Component { id: viewComponent; GameView { width: 1280; height: 720 } }
  function test_viewOffscreen() {
    var view = createTemporaryObject(viewComponent, this)
    verify(view !== null)
    verify(view.menuVisible)
    view.opened = true
    view.begin()
    compare(view.controller.snapshot.status, "running")
    view.opened = false
    compare(view.controller.snapshot.status, "paused")
  }
  function test_boardAndHud() {
    var state = Engine.createGame(42, {playerCount: 2})
    state.regions[0].claimed = true
    var board = createTemporaryObject(boardComponent, this, {snapshot: state})
    var hud = createTemporaryObject(hudComponent, this, {snapshot: state})
    verify(board !== null)
    verify(hud !== null)
    compare(board.claimedCount, 1)
    compare(hud.playerLabel, "PLAYER 1 OF 2")
  }

  function test_keyboardOnlyFlow() {
    var view = createTemporaryObject(viewComponent, this)
    view.opened = true
    verify(view.handleKey(Qt.Key_Return, 0))
    verify(!view.menuVisible)
    compare(view.controller.snapshot.status, "running")

    verify(view.handleKey(Qt.Key_P, 0))
    compare(view.controller.snapshot.status, "paused")
    verify(view.handleKey(Qt.Key_P, 0))
    compare(view.controller.snapshot.status, "running")
  }

  function test_previewFollowsGameState() {
    var view = createTemporaryObject(viewComponent, this)
    view.opened = true
    view.begin()
    view.controller.gameState.spheres = [{ id: 1, regionId: 1, x: 12, y: 5, vx: 0, vy: 0, radius: 0.28 }]
    view.cursorX = 4
    view.cursorY = 4
    verify(view.preview.valid)

    verify(view.controller.placeAt(8, 5))
    verify(!view.preview.valid)
  }
}
