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
  // Object emitting soundRequested(name) and impactRequested(name, gain); GameView.
  property QtObject events: null
  // Collision sounds sit under the cues and repeat at most this often per sound.
  readonly property real impactLevel: 0.45
  readonly property int impactInterval: 70
  property var lastImpactAt: ({})

  readonly property url trackSource: Qt.resolvedUrl("../" + Collection.trackForWave(wave).file)

  function effectNamed(name) {
    for (var i = 0; i < effects.count; i++) {
      var effect = effects.objectAt(i) as SoundEffect
      if (effect && effect.objectName === name) return effect
    }
    return null
  }

  function playSound(name) {
    var effect = effectNamed(name)
    if (!effect) return
    effect.volume = sfxVolume
    effect.play()
  }

  function playImpact(name, gain) {
    var now = Date.now()
    var effect = effectNamed(name)
    if (!effect || sfxVolume <= 0 || now - (lastImpactAt[name] || 0) < impactInterval) return
    lastImpactAt[name] = now
    effect.volume = sfxVolume * impactLevel * gain
    effect.play()
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

    function onImpactRequested(name, gain) {
      root.playImpact(name, gain)
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
    }
  }
}
