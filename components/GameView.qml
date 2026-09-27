pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import "../engine/Input.js" as Input
import "../engine/Collection.js" as Collection
import "../engine/Storage.js" as Storage
import "../engine/Events.js" as Events

// Overlay content: menu, HUD, board, and state dialogs. Kept free of PanelWindow so it
// can be instantiated offscreen by tests.
Item {
  id: root

  property alias controller: game
  property bool opened: false
  property var preferences: Storage.defaultPreferences()
  property var highScores: []
  property bool menuVisible: true
  property int newHighScoreRank: 0
  property real cursorX: 8
  property real cursorY: 5

  readonly property bool reducedMotion: preferences.reducedMotion
  readonly property string status: game.snapshot.status
  readonly property bool dialogVisible: menuVisible || status !== "running"
  readonly property bool musicShouldPlay: opened && !menuVisible && status === "running"
  readonly property var currentArtwork: Collection.artworkForWave(game.snapshot.wave,
    preferences.randomArtwork, preferences.artworkId)
  // Reading `revision` re-evaluates the preview whenever the simulation publishes.
  readonly property var preview: game.revision >= 0 && !menuVisible
    ? game.previewAt(cursorX, cursorY)
    : null

  signal dismissRequested()
  signal persistenceRequested()
  signal soundRequested(string name)

  focus: true
  onOpenedChanged: game.opened = opened
  onPreferencesChanged: persistenceRequested()
  onHighScoresChanged: persistenceRequested()

  function restoreFocus() {
    Qt.callLater(function() { root.forceActiveFocus() })
  }

  function begin() {
    newHighScoreRank = 0
    game.newGame(preferences.difficulty, preferences.playerCount)
    menuVisible = false
    game.start()
    restoreFocus()
  }

  function updatePreference(key, value) {
    var next = Object.assign({}, preferences)
    next[key] = value
    preferences = Storage.sanitizePreferences(next)
  }

  function browse(direction) {
    var index = Collection.artworks.findIndex(function(entry) {
      return entry.id === preferences.artworkId
    })
    var next = (index + direction + Collection.artworks.length) % Collection.artworks.length
    updatePreference("artworkId", Collection.artworks[next].id)
  }

  function adjustSetting(key, direction) {
    var increment = key === "brightness" ? 5 : 0.1
    updatePreference(key, Math.round((preferences[key] + direction * increment) * 100) / 100)
  }

  function recordGameOver() {
    var state = game.snapshot
    var result = Storage.insertHighScore(highScores, {
      score: state.score, wave: state.wave, difficulty: state.difficulty,
      playerCount: state.playerCount, playerScores: state.playerScores,
      date: new Date().toISOString().slice(0, 10)
    })
    highScores = result.scores
    newHighScoreRank = result.rank
  }

  function showMenu() {
    game.backToMenu()
    menuVisible = true
    restoreFocus()
  }

  function dialogTitle() {
    if (menuVisible) return "A gallery in motion"
    if (status === "paused") return "Paused"
    if (status === "level-clear") return "Wave " + game.snapshot.wave + " complete."
    if (status === "game-over") return "Game over"
    return ""
  }

  function dialogMessage() {
    if (menuVisible) return "Claim empty space without touching the moving spheres."
    if (status === "level-clear") {
      var next = Collection.artworkForWave(game.snapshot.wave + 1,
        preferences.randomArtwork, preferences.artworkId)
      return "Next: " + next.title + " — " + next.creator + " · " + next.date
        + "\nTime & life bonus: " + game.snapshot.lastBonus
    }
    if (status === "game-over") return "Final score: " + game.snapshot.score
      + (newHighScoreRank ? "\nNew high score — #" + newHighScoreRank : "")
    if (game.snapshot.playerCount === 2)
      return "Player " + (game.snapshot.activePlayer + 1) + " is painting now."
    return "Take your time."
  }

  function primaryLabel() {
    if (menuVisible) return "START"
    if (status === "paused") return "RESUME"
    if (status === "level-clear") return "NEXT WAVE"
    return "PLAY AGAIN"
  }

  function primaryAction() {
    if (menuVisible || status === "game-over") begin()
    else if (status === "paused") game.togglePause()
    else if (status === "level-clear") game.nextWave()
    restoreFocus()
  }

  function handleEscape() {
    if (!menuVisible && status === "running") game.togglePause()
    else dismissRequested()
  }

  // Returns true when the key was consumed.
  function handleKey(key, modifiers) {
    var action = Input.action(key, modifiers)
    if (action === "escape") {
      handleEscape()
      return true
    }
    if (!opened) return false

    if (dialogVisible) {
      if (action === "place") primaryAction()
      else if (action === "pause" && status === "paused") game.togglePause()
      else return false
      return true
    }

    if (action === "move") {
      var next = Input.move({ x: cursorX, y: cursorY }, key, modifiers)
      cursorX = next.x
      cursorY = next.y
    } else if (action === "place") {
      game.placeAt(cursorX, cursorY)
    } else if (action === "rotate") {
      game.toggleOrientation()
    } else if (action === "pause") {
      game.togglePause()
    } else {
      return false
    }
    return true
  }

  Keys.onPressed: function(event) {
    event.accepted = root.handleKey(event.key, event.modifiers)
  }

  GameController {
    id: game
    property var previousSnapshot: null
    onSnapshotChanged: {
      var events = Events.soundEvents(previousSnapshot, snapshot)
      if (root.opened) events.forEach(function(name) { root.soundRequested(name) })
      if (previousSnapshot && previousSnapshot.status !== "game-over"
          && snapshot.status === "game-over") root.recordGameOver()
      previousSnapshot = snapshot
    }
  }

  Rectangle {
    anchors.fill: parent
    color: "#101b17"
  }

  ColumnLayout {
    anchors.fill: parent
    anchors.margins: Math.max(16, Math.min(root.width, root.height) * 0.035)
    spacing: 12

    Text {
      Layout.alignment: Qt.AlignHCenter
      text: "JEZZ ATELIER"
      color: "#e7cc92"
      font.family: "serif"
      font.pixelSize: Math.max(26, Math.min(48, root.width / 25))
    }

    GameHud {
      Layout.fillWidth: true
      visible: !root.menuVisible
      snapshot: game.snapshot
    }

    GameBoard {
      Layout.fillWidth: true
      Layout.fillHeight: true
      visible: !root.menuVisible
      snapshot: game.snapshot
      randomArtwork: root.preferences.randomArtwork
      artworkId: root.preferences.artworkId
      brightness: root.preferences.brightness
      preview: root.preview
      cursorX: root.cursorX
      cursorY: root.cursorY

      onHovered: function(x, y) {
        root.cursorX = x
        root.cursorY = y
      }
      onPlaced: function(x, y) {
        game.placeAt(x, y)
        root.restoreFocus()
      }
      onRotated: {
        game.toggleOrientation()
        root.restoreFocus()
      }
    }

    Item {
      Layout.fillHeight: true
      visible: root.menuVisible
    }

    Text {
      Layout.fillWidth: true
      visible: !root.menuVisible
      horizontalAlignment: Text.AlignHCenter
      elide: Text.ElideRight
      text: "Now showing: " + root.currentArtwork.title + " — " + root.currentArtwork.creator
        + " (" + root.currentArtwork.date + ")"
      color: "#e7cc92"
      font.family: "serif"
      font.pixelSize: 15
    }

    Text {
      Layout.fillWidth: true
      visible: !root.menuVisible
      text: "ARROWS MOVE · SHIFT + ARROWS FAST · SPACE / ENTER PLACE · R OR RIGHT CLICK ROTATE · P PAUSE · ESC PAUSE / CLOSE"
      wrapMode: Text.Wrap
      horizontalAlignment: Text.AlignHCenter
      color: "#c8ad72"
      font.pixelSize: 12
    }
  }

  Rectangle {
    anchors.centerIn: parent
    width: Math.min(parent.width - 32, 600)
    height: Math.min(parent.height - 32, content.implicitHeight + 40)
    visible: root.dialogVisible
    color: "#1a2b24"
    border.color: "#c8ad72"
    border.width: 2

    Column {
      id: content
      anchors.centerIn: parent
      width: parent.width - 40
      height: Math.min(implicitHeight, parent.height - 32)
      clip: true
      spacing: 14

      Text {
        width: parent.width
        horizontalAlignment: Text.AlignHCenter
        wrapMode: Text.Wrap
        text: root.dialogTitle()
        color: "#f5eedb"
        font.family: "serif"
        font.pixelSize: 27
      }

      Text {
        width: parent.width
        horizontalAlignment: Text.AlignHCenter
        wrapMode: Text.Wrap
        text: root.dialogMessage()
        color: "#e7cc92"
      }

      MenuPanel {
        visible: root.menuVisible
        width: parent.width
        preferences: root.preferences
        highScores: root.highScores
        artwork: root.currentArtwork
        onPreferenceRequested: function(key, value) { root.updatePreference(key, value) }
        onBrowseRequested: function(direction) { root.browse(direction) }
        onAdjustRequested: function(key, direction) { root.adjustSetting(key, direction) }
      }

      AtelierButton {
        width: content.width
        label: root.primaryLabel()
        onActivated: root.primaryAction()
      }

      AtelierButton {
        width: content.width
        visible: !root.menuVisible
        label: "MENU"
        onActivated: root.showMenu()
      }

      AtelierButton {
        width: content.width
        label: "CLOSE"
        onActivated: root.dismissRequested()
      }
    }
  }
}
