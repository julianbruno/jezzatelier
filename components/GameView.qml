pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import "../engine/Input.js" as Input

// Overlay content: menu, HUD, board, and state dialogs. Kept free of PanelWindow so it
// can be instantiated offscreen by tests.
Item {
  id: root

  property alias controller: game
  property bool opened: false
  property bool reducedMotion: false
  property bool menuVisible: true
  property string difficulty: "classic"
  property int playerCount: 1
  property real cursorX: 8
  property real cursorY: 5

  readonly property string status: game.snapshot.status
  readonly property bool dialogVisible: menuVisible || status !== "running"
  // Reading `revision` re-evaluates the preview whenever the simulation publishes.
  readonly property var preview: game.revision >= 0 && !menuVisible
    ? game.previewAt(cursorX, cursorY)
    : null

  readonly property var difficultyNotes: ({
    relaxed: "A gentler pace, five lives and more time to plan.",
    classic: "Three lives and a steady arcade challenge.",
    expert: "Faster spheres, denser waves and a higher capture goal."
  })

  signal dismissRequested()

  focus: true
  onOpenedChanged: game.opened = opened

  function restoreFocus() {
    Qt.callLater(function() { root.forceActiveFocus() })
  }

  function begin() {
    game.newGame(difficulty, playerCount)
    menuVisible = false
    game.start()
    restoreFocus()
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
    if (status === "level-clear") return "Time & life bonus: " + game.snapshot.lastBonus
    if (status === "game-over") return "Final score: " + game.snapshot.score
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
      text: "ARROWS MOVE · SHIFT + ARROWS FAST · SPACE / ENTER PLACE · R OR RIGHT CLICK ROTATE · P PAUSE · ESC PAUSE / CLOSE"
      wrapMode: Text.Wrap
      horizontalAlignment: Text.AlignHCenter
      color: "#c8ad72"
      font.pixelSize: 12
    }
  }

  Rectangle {
    anchors.centerIn: parent
    width: Math.min(parent.width - 32, 480)
    implicitHeight: content.implicitHeight + 40
    visible: root.dialogVisible
    color: "#1a2b24"
    border.color: "#c8ad72"
    border.width: 2

    Column {
      id: content
      anchors.centerIn: parent
      width: parent.width - 40
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

      Column {
        visible: root.menuVisible
        width: parent.width
        spacing: 8

        Text {
          text: "DIFFICULTY"
          color: "#c8ad72"
          font.pixelSize: 12
        }

        Repeater {
          model: ["relaxed", "classic", "expert"]

          AtelierButton {
            required property string modelData
            width: content.width
            label: modelData.toUpperCase() + (root.difficulty === modelData ? "  ●" : "")
            onActivated: root.difficulty = modelData
          }
        }

        Text {
          width: parent.width
          wrapMode: Text.Wrap
          text: root.difficultyNotes[root.difficulty]
          color: "#f5eedb"
        }

        AtelierButton {
          width: content.width
          label: root.playerCount === 1 ? "1 PLAYER" : "2 PLAYERS · HOT-SEAT"
          onActivated: root.playerCount = root.playerCount === 1 ? 2 : 1
        }
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
