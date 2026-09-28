import QtQuick
import QtTest
import "../components"
import "../engine/Engine.js" as Engine

TestCase {
  name: "View"
  width: 1280
  height: 800
  Component { id: boardComponent; GameBoard { width: 640; height: 400 } }
  Component { id: hudComponent; GameHud {} }
  Component { id: menuComponent; MenuPanel { width: 560 } }
  Component { id: viewComponent; GameView { width: 1280; height: 720 } }
  when: windowShown

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
    var state = Engine.createGame(42)
    state.regions[0].claimed = true
    var board = createTemporaryObject(boardComponent, this, {snapshot: state})
    var hud = createTemporaryObject(hudComponent, this, {snapshot: state})
    verify(board !== null)
    verify(hud !== null)
    compare(board.claimedCount, 1)
    compare(hud.maxLives, 3)
    compare(hud.timeFraction, 1)
    compare(hud.coverageFraction, 0)
    near(hud.targetFraction, 0.75)
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

  function test_preferencesAndScoreAndAudio() {
    var view = createTemporaryObject(viewComponent, this)
    view.preferences = { difficulty: "expert", randomArtwork: false,
      artworkId: "vermeer-delft", brightness: 60, musicVolume: 0.4,
      sfxVolume: 0.2, reducedMotion: true }
    view.opened = true
    view.begin()
    compare(view.controller.snapshot.difficulty, "expert")
    compare(view.currentArtwork.id, "vermeer-delft")
    verify(view.musicShouldPlay)
    view.controller.togglePause()
    verify(!view.musicShouldPlay)
    view.controller.togglePause()
    view.controller.gameState.status = "game-over"
    view.controller.publish()
    compare(view.newHighScoreRank, 1)
    compare(view.highScores.length, 1)
    verify(!view.musicShouldPlay)
    view.opened = false
    verify(!view.musicShouldPlay)
  }

  function test_boardArtworkSelection() {
    var board = createTemporaryObject(boardComponent, this)
    board.snapshot = { wave: 2, regions: [], walls: [], spheres: [], growingWall: null }
    compare(board.artwork.id, "lorrain-harbour")
    board.randomArtwork = false
    board.artworkId = "vermeer-delft"
    compare(board.artwork.id, "vermeer-delft")
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

  function test_claimedRegionsStandOutFromVeiledField() {
    var veils = [100, 82, 45].map(function(brightness) {
      var board = createTemporaryObject(boardComponent, this, { brightness: brightness })
      return board.veilOpacity
    }, this)
    verify(veils[0] >= 0.25, "veil at 100: " + veils[0])
    verify(veils[1] >= 0.4, "veil at default 82: " + veils[1])
    verify(veils[2] <= 0.8, "veil at 45: " + veils[2])
    verify(veils[0] < veils[1] && veils[1] < veils[2])
  }

  function test_menuUsesHumanLabels() {
    var menu = createTemporaryObject(menuComponent, this)
    compare(menu.settingLabel("brightness", 82), "Brightness 82%")
    compare(menu.settingLabel("musicVolume", 0.6), "Music 60%")
    compare(menu.settingLabel("sfxVolume", 0.8), "Effects 80%")
    compare(menu.galleryModeLabel(true), "MODE · TOUR BY WAVE")
    compare(menu.galleryModeLabel(false), "MODE · FIXED PAINTING")
  }

  // Loads the optional audio director exactly as JezzAtelier.qml does, without playing.
  function test_audioDirectorLoadsWhenQtMultimediaIsPresent() {
    var component = Qt.createComponent(Qt.resolvedUrl("../components/AudioDirector.qml"))
    compare(component.status, Component.Ready, component.errorString())
    var audio = component.createObject(this, { shouldPlay: false }) as AudioDirector
    verify(audio !== null)
    compare(audio.trackSource.toString().slice(-12), "bach-01.opus")
    audio.destroy()
  }

  function near(actual, expected) {
    verify(Math.abs(actual - expected) < 0.000001, actual + " != " + expected)
  }

  function test_orientationIsDiscoverableAndSwitchable() {
    var view = createTemporaryObject(viewComponent, this)
    view.opened = true
    view.begin()
    compare(view.orientationLabel(), "↕  VERTICAL CUT")
    view.rotate()
    compare(view.controller.snapshot.orientation, "horizontal")
    compare(view.orientationLabel(), "↔  HORIZONTAL CUT")
  }

  function test_wheelRotatesOncePerNotch() {
    var board = createTemporaryObject(boardComponent, this, {
      snapshot: Engine.createGame(1, {})
    })
    var rotations = 0
    board.rotated.connect(function() { rotations++ })
    board.handleWheel(120)
    compare(rotations, 1)
    for (var i = 0; i < 4; i++) board.handleWheel(-15)
    compare(rotations, 1)
    for (var j = 0; j < 4; j++) board.handleWheel(-15)
    compare(rotations, 2)
  }

  function test_rejectedPlacementExplainsWhy() {
    var view = createTemporaryObject(viewComponent, this)
    view.opened = true
    view.begin()
    view.controller.gameState.spheres = [{ id: 1, regionId: 1, x: 12, y: 5, vx: 0, vy: 0, radius: 0.28 }]

    verify(!view.placeAt(12.1, 5))
    compare(view.toastText, "Too close to a sphere or an edge")
    compare(view.toastTone, "loss")

    verify(view.placeAt(4, 4))
    compare(view.controller.snapshot.growingWall !== null, true)
    verify(!view.placeAt(6, 6))
    compare(view.toastText, "One wall at a time")
  }

  function test_ultrawideUsesSidePanel() {
    var wide = createTemporaryObject(viewComponent, this, { width: 2560, height: 1080 })
    verify(wide.wideLayout)
    var standard = createTemporaryObject(viewComponent, this, { width: 1280, height: 800 })
    verify(!standard.wideLayout)
  }

  // Holding Enter to start must not also build a wall when the key starts repeating.
  function test_autoRepeatOnlyMovesTheCursor() {
    var view = createTemporaryObject(viewComponent, this)
    view.opened = true
    verify(view.handleKey(Qt.Key_Return, 0, false))
    compare(view.controller.snapshot.status, "running")

    verify(view.handleKey(Qt.Key_Return, 0, true))
    compare(view.controller.snapshot.growingWall, null)
    verify(view.handleKey(Qt.Key_R, 0, true))
    compare(view.controller.snapshot.orientation, "vertical")
    verify(view.handleKey(Qt.Key_P, 0, true))
    compare(view.controller.snapshot.status, "running")

    var x = view.cursorX
    verify(view.handleKey(Qt.Key_Right, 0, true))
    verify(view.cursorX > x)
  }

  function test_impactsRequestCollisionSounds() {
    var view = createTemporaryObject(viewComponent, this)
    var spy = createTemporaryObject(signalSpyComponent, this, { target: view, signalName: "impactRequested" })
    view.opened = true
    view.begin()
    var previous = view.controller.snapshot
    var next = JSON.parse(JSON.stringify(previous))
    next.impacts = [{ kind: "sphere", speed: 4, x: 1, y: 1 }]
    view.reactToSnapshot(previous, next)
    compare(spy.count, 1)
    compare(spy.signalArguments[0][0], "clack")
    compare(spy.signalArguments[0][1], 0.5)
  }

  Component { id: signalSpyComponent; SignalSpy {} }
}
