pragma ComponentBehavior: Bound
import QtQuick
import QtQml.Models
import QtMultimedia
import "../engine/Collection.js" as Collection

// Music and sound effects. Loaded through a Loader only while the overlay is open, so
// closing the overlay destroys every player; a missing QtMultimedia leaves the game silent.
Item {
  id: root

  property bool shouldPlay: false
  property int wave: 1
  property real musicVolume: 0.6
  property real sfxVolume: 0.8
  // Object emitting soundRequested(name); GameView in the overlay.
  property QtObject events: null

  readonly property url trackSource: Qt.resolvedUrl("../" + Collection.trackForWave(wave).file)

  function playSound(name) {
    for (var i = 0; i < effects.count; i++) {
      var effect = effects.objectAt(i) as SoundEffect
      if (effect && effect.objectName === name) effect.play()
    }
  }

  function syncMusic() {
    if (shouldPlay && musicVolume > 0) player.play()
    else player.pause()
  }

  onShouldPlayChanged: syncMusic()
  onMusicVolumeChanged: syncMusic()
  onTrackSourceChanged: syncMusic()
  Component.onCompleted: syncMusic()

  Connections {
    target: root.events
    ignoreUnknownSignals: true

    function onSoundRequested(name) {
      root.playSound(name)
    }
  }

  MediaPlayer {
    id: player
    source: root.trackSource
    loops: MediaPlayer.Infinite
    audioOutput: AudioOutput {
      volume: root.musicVolume
    }
  }

  Instantiator {
    id: effects
    model: Object.keys(Collection.sfx)

    SoundEffect {
      required property string modelData
      objectName: modelData
      source: Qt.resolvedUrl("../" + Collection.sfxFile(modelData))
      volume: root.sfxVolume
    }
  }
}
