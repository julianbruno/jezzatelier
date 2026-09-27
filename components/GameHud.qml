import QtQuick

Flow {
  id: root
  property var snapshot: null
  readonly property string playerLabel: snapshot ? "PLAYER " + (snapshot.activePlayer + 1) + " OF " + snapshot.playerCount : ""
  spacing: 14
  Repeater {
    model: root.snapshot ? [
      "WAVE " + root.snapshot.wave,
      "TIME " + Math.ceil(root.snapshot.timeRemaining) + "s",
      "SCORE " + root.snapshot.score,
      "LIVES " + root.snapshot.lives,
      "COVERAGE " + Math.round(root.snapshot.coverage * 100) + "% / " + Math.round(root.snapshot.targetCoverage * 100) + "%",
      root.playerLabel,
      root.snapshot.playerCount === 2 ? "P1 " + root.snapshot.playerScores[0] + " · P2 " + root.snapshot.playerScores[1] : "",
      root.snapshot.orientation.toUpperCase()
    ] : []
    Text {
      required property string modelData
      visible: modelData.length > 0
      text: modelData
      color: "#f5eedb"
      font.pixelSize: 13
      font.bold: true
    }
  }
}
