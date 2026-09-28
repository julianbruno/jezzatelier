import QtQuick
import QtTest
import "../components"

TestCase {
  name: "Controller"
  Component { id: controllerComponent; GameController {} }
  function test_lifecycle() {
    var game = createTemporaryObject(controllerComponent, this)
    verify(game !== null)
    game.newGame("expert", 42)
    compare(game.snapshot.difficulty, "expert")
    compare(game.snapshot.seed, 42)
    verify(!game.frameActive)
    game.opened = true
    game.start()
    verify(game.frameActive)
    game.togglePause()
    verify(!game.frameActive)
    game.togglePause()
    game.opened = false
    compare(game.snapshot.status, "paused")
    verify(!game.frameActive)
  }
  function test_actions() {
    var game = createTemporaryObject(controllerComponent, this)
    game.newGame("classic", 42)
    game.opened = true
    game.start()
    game.toggleOrientation()
    compare(game.snapshot.orientation, "horizontal")
    verify(game.placeAt(8, 5))
    verify(game.snapshot.growingWall !== null)
    verify(!game.nextWave())
    game.gameState.status = "level-clear"
    verify(game.nextWave())
    compare(game.snapshot.wave, 2)
  }

  function test_frameHitchDoesNotDrainClock() {
    var game = createTemporaryObject(controllerComponent, this)
    game.newGame("classic", 42)
    game.opened = true
    game.start()
    game.advance(5)
    compare(game.snapshot.timeRemaining, 105 - game.maxFrameTime)
  }
}
