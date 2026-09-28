pragma ComponentBehavior: Bound
import QtQuick
import "../engine/Collection.js" as Collection

// Tabbed main-menu content: play setup, gallery, settings, scores, and credits.
// It only renders preferences and reports intents; GameView owns the state.
Column {
  id: root

  property var preferences: ({})
  property var highScores: []
  property var artwork: Collection.artworks[0]
  property string section: "Play"
  property real maxContentHeight: 340

  readonly property var sections: ["Play", "Gallery", "Settings", "Scores", "Credits"]
  readonly property var difficultyNotes: ({
    relaxed: "A gentler pace, five lives and more time to plan.",
    classic: "Three lives and a steady arcade challenge.",
    expert: "Faster spheres, denser waves and a higher capture goal."
  })
  readonly property var settingNames: ({
    brightness: "Brightness",
    musicVolume: "Music",
    sfxVolume: "Effects"
  })

  signal preferenceRequested(string key, var value)
  signal browseRequested(int direction)
  signal adjustRequested(string key, int direction)

  spacing: 10

  function settingLabel(key, value) {
    var percent = key === "brightness" ? value : value * 100
    return settingNames[key] + " " + Math.round(percent) + "%"
  }

  function galleryModeLabel(randomArtwork) {
    return randomArtwork ? "MODE · TOUR BY WAVE" : "MODE · FIXED PAINTING"
  }

  function artworkPosition() {
    var index = Collection.artworks.findIndex(function(entry) { return entry.id === root.artwork.id })
    return (index + 1) + " / " + Collection.artworks.length
  }

  function scoreLine(entry, index) {
    return "#" + (index + 1) + "   " + entry.score + "   wave " + entry.wave + " · "
      + entry.difficulty + " · " + entry.playerCount + "P · " + entry.date
  }

  function creditLine(entry) {
    var date = entry.date ? " (" + entry.date + ")" : ""
    return entry.title + " — " + entry.creator + date + " · " + entry.license + "\n" + entry.sourceUrl
  }

  Row {
    spacing: 4

    Repeater {
      model: root.sections

      AtelierButton {
        required property string modelData
        width: (root.width - 16) / root.sections.length
        implicitWidth: 0
        label: modelData
        selected: root.section === modelData
        onActivated: root.section = modelData
      }
    }
  }

  Flickable {
    width: root.width
    height: Math.min(root.maxContentHeight, sectionContent.implicitHeight)
    contentHeight: sectionContent.implicitHeight
    clip: true

    Column {
      id: sectionContent
      width: root.width
      spacing: 8

      Column {
        visible: root.section === "Play"
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
            width: root.width
            label: modelData.toUpperCase()
            selected: root.preferences.difficulty === modelData
            onActivated: root.preferenceRequested("difficulty", modelData)
          }
        }

        Text {
          width: parent.width
          wrapMode: Text.Wrap
          text: root.difficultyNotes[root.preferences.difficulty] || ""
          color: "#f5eedb"
        }

        Text {
          text: "PLAYERS"
          color: "#c8ad72"
          font.pixelSize: 12
        }

        Row {
          spacing: 8

          AtelierButton {
            width: (root.width - 8) / 2
            implicitWidth: 0
            label: "1 PLAYER"
            selected: root.preferences.playerCount !== 2
            onActivated: root.preferenceRequested("playerCount", 1)
          }

          AtelierButton {
            width: (root.width - 8) / 2
            implicitWidth: 0
            label: "2 PLAYERS · HOT-SEAT"
            selected: root.preferences.playerCount === 2
            onActivated: root.preferenceRequested("playerCount", 2)
          }
        }

        Text {
          width: parent.width
          wrapMode: Text.Wrap
          color: "#e7cc92"
          font.pixelSize: 13
          lineHeight: 1.35
          text: "Click to grow a wall; right-click, the wheel, or R turns it horizontal or vertical. "
            + "Enclose space with no sphere inside to uncover the painting. "
            + "A sphere touching a growing wall breaks it and costs a life."
        }
      }

      Column {
        visible: root.section === "Gallery"
        width: parent.width
        spacing: 8

        AtelierButton {
          width: root.width
          label: root.galleryModeLabel(root.preferences.randomArtwork)
          onActivated: root.preferenceRequested("randomArtwork", !root.preferences.randomArtwork)
        }

        Row {
          visible: !root.preferences.randomArtwork
          anchors.horizontalCenter: parent.horizontalCenter
          spacing: 8

          AtelierButton {
            label: "← PREVIOUS"
            onActivated: root.browseRequested(-1)
          }

          AtelierButton {
            label: "NEXT →"
            onActivated: root.browseRequested(1)
          }
        }

        Image {
          width: root.width
          height: Math.round(root.width * 0.3)
          asynchronous: true
          fillMode: Image.PreserveAspectFit
          sourceSize.height: height
          source: Qt.resolvedUrl("../" + root.artwork.file)
        }

        Text {
          width: parent.width
          wrapMode: Text.Wrap
          horizontalAlignment: Text.AlignHCenter
          color: "#f5eedb"
          text: root.artwork.title + " — " + root.artwork.creator + " (" + root.artwork.date + ")\n"
            + root.artwork.license + " · " + root.artworkPosition()
        }
      }

      Column {
        visible: root.section === "Settings"
        width: parent.width
        spacing: 8

        Repeater {
          model: ["brightness", "musicVolume", "sfxVolume"]

          Row {
            id: settingRow

            required property string modelData

            spacing: 8

            Text {
              width: root.width - 2 * 64 - 16
              anchors.verticalCenter: parent.verticalCenter
              color: "#f5eedb"
              text: root.settingLabel(settingRow.modelData, root.preferences[settingRow.modelData])
            }

            AtelierButton {
              width: 64
              implicitWidth: 0
              label: "−"
              onActivated: root.adjustRequested(settingRow.modelData, -1)
            }

            AtelierButton {
              width: 64
              implicitWidth: 0
              label: "+"
              onActivated: root.adjustRequested(settingRow.modelData, 1)
            }
          }
        }

        AtelierButton {
          width: root.width
          label: root.preferences.reducedMotion ? "REDUCED MOTION · ON" : "REDUCED MOTION · OFF"
          onActivated: root.preferenceRequested("reducedMotion", !root.preferences.reducedMotion)
        }
      }

      Column {
        visible: root.section === "Scores"
        width: parent.width
        spacing: 4

        Text {
          visible: root.highScores.length === 0
          color: "#c8ad72"
          text: "No scores yet. Finish a game to start the ledger."
        }

        Repeater {
          model: root.highScores

          Text {
            required property var modelData
            required property int index
            color: "#f5eedb"
            text: root.scoreLine(modelData, index)
          }
        }
      }

      Column {
        visible: root.section === "Credits"
        width: parent.width
        spacing: 6

        Repeater {
          model: Collection.artworks.concat(Collection.tracks)

          Text {
            required property var modelData
            width: root.width
            wrapMode: Text.WrapAnywhere
            color: "#f5eedb"
            font.pixelSize: 12
            text: root.creditLine(modelData)
          }
        }

        Text {
          width: root.width
          wrapMode: Text.Wrap
          color: "#f5eedb"
          font.pixelSize: 12
          text: "Sound effects (build, capture, life lost, wave clear, game over, rail bounce, sphere clack): original works by the project, CC0 1.0."
        }
      }
    }
  }
}
