pragma ComponentBehavior: Bound
import QtQuick
import "Theme.js" as Theme
import "../engine/Engine.js" as Engine

// Game status: wave, score, lives, time and coverage gauges, and hot-seat scores.
Flow {
  id: root

  property var snapshot: null

  readonly property var waveProfile: snapshot ? Engine.profile(snapshot.wave, snapshot.difficulty) : null
  readonly property int maxLives: snapshot ? Engine.profile(1, snapshot.difficulty).lives : 0
  readonly property real timeFraction: waveProfile ? snapshot.timeRemaining / waveProfile.timeLimit : 0
  readonly property real coverageFraction: snapshot ? snapshot.coverage : 0
  readonly property real targetFraction: snapshot ? snapshot.targetCoverage : 0
  readonly property bool timeRunningOut: snapshot !== null && snapshot.timeRemaining < 15

  spacing: 28

  StatBlock {
    caption: "WAVE"
    value: root.snapshot ? String(root.snapshot.wave) : ""
  }

  StatBlock {
    caption: "SCORE"
    value: root.snapshot ? root.snapshot.score.toLocaleString(Qt.locale("en_US"), "f", 0) : ""
  }

  StatBlock {
    caption: "LIVES"

    Row {
      spacing: 6

      Repeater {
        model: root.maxLives

        Rectangle {
          required property int index
          width: 14
          height: 14
          radius: 7
          color: index < root.snapshot.lives ? Theme.danger : "transparent"
          border.color: Theme.danger
          border.width: 2
        }
      }
    }
  }

  StatBlock {
    caption: "TIME"
    value: root.snapshot ? Math.ceil(root.snapshot.timeRemaining) + " s" : ""
    valueColor: root.timeRunningOut ? Theme.danger : Theme.ivory

    ProgressBar {
      fraction: root.timeFraction
      fill: root.timeRunningOut ? Theme.danger : Theme.focus
    }
  }

  StatBlock {
    caption: "CLAIMED · GOAL " + Math.round(root.targetFraction * 100) + "%"
    value: Math.round(root.coverageFraction * 100) + "%"
    valueColor: root.coverageFraction >= root.targetFraction ? Theme.goldBright : Theme.ivory

    ProgressBar {
      fraction: root.coverageFraction
      target: root.targetFraction
    }
  }
}
