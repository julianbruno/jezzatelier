pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import "Theme.js" as Theme
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
  property string toastText: ""
  property string toastTone: "info"

  readonly property bool reducedMotion: preferences.reducedMotion
  // Ultrawide screens get a side panel so the 16:10 board can use the full height.
  readonly property bool wideLayout: width / Math.max(1, height) > 1.9
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

  function showToast(text, tone) {
    toastText = text
    toastTone = tone
    toastTimer.restart()
  }

  // Returns whether a wall was started; explains a refusal in a toast.
  function placeAt(x, y) {
    if (game.placeAt(x, y)) return true
    showToast(Events.placementRejection(game.snapshot, game.previewAt(x, y)), "loss")
    return false
  }

  function rotate() {
    game.toggleOrientation()
  }

  function orientationLabel() {
    return game.snapshot.orientation === "vertical" ? "↕  VERTICAL CUT" : "↔  HORIZONTAL CUT"
  }

  function reactToSnapshot(previous, next) {
    if (!opened || !previous) return

    Events.soundEvents(previous, next).forEach(function(name) { root.soundRequested(name) })
    var messages = Events.feedback(previous, next)
    if (messages.length > 0) {
      var texts = messages.map(function(message) { return message.text })
      showToast(texts.join("  ·  "), messages[0].tone)
    }
    board.flashClaims(Events.newlyClaimed(previous, next))
    if (next.lives < previous.lives) board.flashLoss()
    if (previous.status !== "game-over" && next.status === "game-over") recordGameOver()
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
    if (menuVisible) return "JEZZ ATELIER"
    if (status === "paused") return "Paused"
    if (status === "level-clear") return "Wave " + game.snapshot.wave + " complete."
    if (status === "game-over") return "Game over"
    return ""
  }

  function dialogMessage() {
    if (menuVisible) return "A gallery in motion"
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

  // Returns true when the key was consumed. Auto-repeat only moves the cursor: a held
  // Enter that started the game must not also build a wall a quarter second later.
  function handleKey(key, modifiers, isAutoRepeat) {
    var action = Input.action(key, modifiers)
    if (isAutoRepeat && action !== "" && action !== "move") return true
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
      placeAt(cursorX, cursorY)
    } else if (action === "rotate") {
      rotate()
    } else if (action === "pause") {
      game.togglePause()
    } else {
      return false
    }
    return true
  }

  Keys.onPressed: function(event) {
    event.accepted = root.handleKey(event.key, event.modifiers, event.isAutoRepeat)
  }

  GameController {
    id: game

    property var previousSnapshot: null

    onSnapshotChanged: {
      root.reactToSnapshot(previousSnapshot, snapshot)
      previousSnapshot = snapshot
    }
  }

  Timer {
    id: toastTimer
    interval: 1800
    onTriggered: root.toastText = ""
  }

  Rectangle {
    anchors.fill: parent
    color: Theme.ink
  }

  // The menu sits on the painting it is about to reveal.
  Image {
    anchors.fill: parent
    visible: root.menuVisible
    source: Qt.resolvedUrl("../" + root.currentArtwork.file)
    fillMode: Image.PreserveAspectCrop
    asynchronous: true
    sourceSize.width: Math.ceil(width / 2)
    opacity: 0.22
  }

  GridLayout {
    id: layout

    anchors.fill: parent
    anchors.margins: Math.max(16, Math.min(root.width, root.height) * 0.03)
    visible: !root.menuVisible
    columns: root.wideLayout ? 2 : 1
    rowSpacing: 12
    columnSpacing: 36

    ColumnLayout {
      Layout.fillWidth: !root.wideLayout
      Layout.preferredWidth: root.wideLayout ? Math.min(420, root.width * 0.2) : -1
      Layout.fillHeight: root.wideLayout
      Layout.alignment: Qt.AlignTop
      spacing: root.wideLayout ? 22 : 10

      Flow {
        Layout.fillWidth: true
        spacing: 28

        Text {
          id: gameTitle
          text: "JEZZ ATELIER"
          color: Theme.goldBright
          font.family: Theme.serif
          font.pixelSize: root.wideLayout ? 32 : 26
          font.letterSpacing: 2
        }

        GameHud {
          width: root.wideLayout ? parent.width : parent.width - gameTitle.width - parent.spacing
          snapshot: game.snapshot
        }
      }

      Flow {
        Layout.fillWidth: true
        spacing: 10

        AtelierButton {
          implicitHeight: 38
          label: root.orientationLabel()
          selected: true
          onActivated: {
            root.rotate()
            root.restoreFocus()
          }
        }

        AtelierButton {
          implicitHeight: 38
          label: "PAUSE"
          onActivated: {
            game.togglePause()
            root.restoreFocus()
          }
        }

        AtelierButton {
          implicitHeight: 38
          label: "MENU"
          onActivated: root.showMenu()
        }
      }

      Item {
        visible: root.wideLayout
        Layout.fillHeight: true
      }

      Text {
        Layout.fillWidth: true
        wrapMode: Text.Wrap
        text: "Now showing\n" + root.currentArtwork.title + " — " + root.currentArtwork.creator
          + " (" + root.currentArtwork.date + ")"
        color: Theme.goldBright
        font.family: Theme.serif
        font.italic: true
        font.pixelSize: 15
        visible: root.wideLayout
      }

      Text {
        Layout.fillWidth: true
        wrapMode: Text.Wrap
        text: root.wideLayout
          ? "CLICK  build\nRIGHT-CLICK · WHEEL · R  rotate\nARROWS + SPACE  build from keyboard\nP  pause     ESC  pause / close"
          : "CLICK BUILD  ·  RIGHT-CLICK, WHEEL OR R ROTATE  ·  ARROWS + SPACE BUILD FROM KEYBOARD  ·  P PAUSE  ·  ESC PAUSE / CLOSE"
        color: Theme.gold
        font.pixelSize: 11
        font.letterSpacing: 0.8
        lineHeight: 1.4
      }
    }

    GameBoard {
      id: board

      Layout.fillWidth: true
      Layout.fillHeight: true
      snapshot: game.snapshot
      randomArtwork: root.preferences.randomArtwork
      artworkId: root.preferences.artworkId
      brightness: root.preferences.brightness
      reducedMotion: root.reducedMotion
      interactive: root.status === "running"
      preview: root.preview
      cursorX: root.cursorX
      cursorY: root.cursorY

      onHovered: function(x, y) {
        root.cursorX = x
        root.cursorY = y
      }
      onPlaced: function(x, y) {
        root.placeAt(x, y)
        root.restoreFocus()
      }
      onRotated: {
        root.rotate()
        root.restoreFocus()
      }
    }

    Text {
      visible: !root.wideLayout
      Layout.fillWidth: true
      horizontalAlignment: Text.AlignHCenter
      elide: Text.ElideRight
      text: "Now showing  " + root.currentArtwork.title + " — " + root.currentArtwork.creator
        + " (" + root.currentArtwork.date + ")"
      color: Theme.goldBright
      font.family: Theme.serif
      font.italic: true
      font.pixelSize: 15
    }
  }

  Rectangle {
    id: toast

    readonly property color accent: root.toastTone === "loss"
      ? Theme.danger
      : (root.toastTone === "gain" ? Theme.goldBright : Theme.focus)

    x: layout.x + board.x + board.box.x + (board.box.width - width) / 2
    y: layout.y + board.y + board.box.y + 18
    width: toastLabel.implicitWidth + 36
    height: toastLabel.implicitHeight + 16
    radius: height / 2
    visible: opacity > 0
    opacity: root.toastText.length > 0 && !root.dialogVisible ? 1 : 0
    color: "#e6101b17"
    border.color: accent
    border.width: 2

    Behavior on opacity {
      enabled: !root.reducedMotion
      NumberAnimation { duration: 180 }
    }

    Text {
      id: toastLabel
      anchors.centerIn: parent
      text: root.toastText
      color: toast.accent
      font.pixelSize: 16
      font.bold: true
    }
  }

  Rectangle {
    anchors.fill: parent
    visible: root.dialogVisible && !root.menuVisible
    color: Theme.ink
    opacity: 0.62
  }

  Rectangle {
    anchors.centerIn: parent
    width: Math.min(parent.width - 32, 600)
    height: Math.min(parent.height - 32, content.implicitHeight + 40)
    visible: root.dialogVisible
    color: Theme.surface
    border.color: Theme.gold
    border.width: 2
    radius: 6

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
        color: root.menuVisible ? Theme.goldBright : Theme.ivory
        font.family: Theme.serif
        font.pixelSize: root.menuVisible ? 38 : 28
        font.letterSpacing: root.menuVisible ? 4 : 0
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
        // Everything in the dialog except the section content takes about 330 px.
        maxContentHeight: Math.max(160, root.height - 360)
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
        primary: true
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
