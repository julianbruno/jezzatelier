import QtQuick
import QtTest
import "../engine/Storage.js" as Storage

TestCase {
  name: "Storage"

  function test_defaultsAndSanitization() {
    var defaults = Storage.defaultPreferences()
    compare(defaults.difficulty, "classic")
    compare(defaults.playerCount, undefined)
    compare(defaults.brightness, 82)
    compare(defaults.musicVolume, 0.6)
    compare(defaults.sfxVolume, 0.8)
    compare(Storage.sanitizePreferences(null).artworkId, defaults.artworkId)
    var clean = Storage.sanitizePreferences({ difficulty: "alien", playerCount: 3,
      artworkId: "missing", brightness: 999, musicVolume: -4, sfxVolume: 4,
      randomArtwork: false, reducedMotion: true, extra: "discard" })
    compare(clean.difficulty, "classic")
    compare(clean.playerCount, undefined)
    compare(clean.artworkId, defaults.artworkId)
    compare(clean.brightness, 100)
    compare(clean.musicVolume, 0)
    compare(clean.sfxVolume, 1)
    compare(clean.randomArtwork, false)
    compare(clean.reducedMotion, true)
    verify(clean.extra === undefined)
    compare(Storage.sanitizePreferences({ brightness: "bad" }).brightness, 82)
  }

  function test_corruptAndRoundTrip() {
    compare(Storage.parseState("broken").version, 1)
    compare(Storage.parseState("null").highScores.length, 0)
    compare(Storage.parseState("{}").preferences.brightness, 82)
    var state = Storage.parseState('{"preferences":{"brightness":20},"highScores":[{"score":4,"wave":2,"difficulty":"classic","playerCount":1,"playerScores":[4],"date":"2025-01-01"}]}')
    compare(state.preferences.brightness, 45)
    compare(state.highScores.length, 1)
    compare(Storage.parseState(Storage.serializeState(state)).highScores[0].score, 4)
    compare(state.highScores[0].playerCount, undefined)
    compare(state.highScores[0].playerScores, undefined)
    compare(JSON.parse(Storage.serializeState(state)).version, 1)
  }

  function test_rankingAndLimit() {
    function entry(score, wave, date) {
      return { score: score, wave: wave, difficulty: "classic", date: date }
    }
    var first = Storage.insertHighScore([], entry(50, 2, "2025-02-01"), 2)
    compare(first.rank, 1)
    var second = Storage.insertHighScore(first.scores, entry(50, 2, "2025-01-01"), 2)
    compare(second.rank, 1)
    var third = Storage.insertHighScore(second.scores, entry(50, 3, "2025-03-01"), 2)
    compare(third.rank, 1)
    compare(third.scores[1].date, "2025-01-01")
    var rejected = Storage.insertHighScore(third.scores, entry(1, 1, "2025-04-01"), 2)
    compare(rejected.rank, 0)
    compare(rejected.scores.length, 2)
    compare(Storage.insertHighScore([], entry(1, 1, "2025-01-01")).rank, 1)
  }
}
