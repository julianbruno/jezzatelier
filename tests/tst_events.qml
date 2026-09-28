import QtQuick
import QtTest
import "../engine/Events.js" as Events

TestCase {
  name: "Events"

  function test_orderedDiffs() {
    var before = { growingWall: null, walls: [], lives: 2, status: "running" }
    var after = { growingWall: {}, walls: [{}], lives: 1, status: "game-over" }
    compare(Events.soundEvents(null, after).length, 0)
    compare(Events.soundEvents(before, after).join(","), "build,capture,life-lost,game-over")
    after.status = "level-clear"
    compare(Events.soundEvents(before, after).join(","), "build,capture,life-lost,level-clear")
    compare(Events.soundEvents(after, after).length, 0)
  }

  function snapshot(overrides) {
    var base = {
      status: "running", lives: 3, playerCount: 1, activePlayer: 0, coverage: 0, walls: [],
      regions: [{ id: 1, claimed: false }]
    }
    return Object.assign(base, overrides || {})
  }

  function test_feedbackForCapture() {
    var before = snapshot()
    var after = snapshot({
      coverage: 0.375, walls: [{}],
      regions: [{ id: 2, claimed: true }, { id: 3, claimed: false }]
    })
    var messages = Events.feedback(before, after)
    compare(messages.length, 1)
    compare(messages[0].tone, "gain")
    compare(messages[0].text, "+3750 · 38% claimed")
  }

  function test_feedbackForBrokenWall() {
    compare(Events.feedback(snapshot(), snapshot({ lives: 2 }))[0].text, "Wall broken · 2 lives left")
    compare(Events.feedback(snapshot({ lives: 2 }), snapshot({ lives: 1 }))[0].text, "Wall broken · last life")
    compare(Events.feedback(snapshot({ lives: 2 }), snapshot({ lives: 1 }))[0].tone, "loss")
  }

  function test_feedbackForTurnChange() {
    var before = snapshot({ playerCount: 2 })
    var after = snapshot({ playerCount: 2, activePlayer: 1, lives: 2 })
    var texts = Events.feedback(before, after).map(function(message) { return message.text })
    compare(texts.join(" | "), "Wall broken · 2 lives left | Player 2's turn")
    compare(Events.feedback(null, after).length, 0)
    compare(Events.feedback(after, after).length, 0)
  }

  function test_placementRejectionReasons() {
    compare(Events.placementRejection({ growingWall: {} }, { regionId: 1 }), "One wall at a time")
    compare(Events.placementRejection({ growingWall: null }, { regionId: null }), "That space is already claimed")
    compare(Events.placementRejection({ growingWall: null }, { regionId: 1 }), "Too close to a sphere or an edge")
  }

  function test_newlyClaimedRegions() {
    var before = snapshot({ regions: [{ id: 2, claimed: true }, { id: 3, claimed: false }] })
    var after = snapshot({ regions: [{ id: 2, claimed: true }, { id: 4, claimed: true }, { id: 5, claimed: false }] })
    compare(Events.newlyClaimed(before, after).map(function(region) { return region.id }).join(","), "4")
    compare(Events.newlyClaimed(null, after).length, 0)
  }

  function test_feedbackForWallThatEnclosesNothing() {
    var after = snapshot({ walls: [{}], regions: [{ id: 2, claimed: false }, { id: 3, claimed: false }] })
    var messages = Events.feedback(snapshot(), after)
    compare(messages[0].text, "Wall built · nothing enclosed")
    compare(messages[0].tone, "info")
  }

  function test_impactSoundsKeepTheStrongestHitOfEachKind() {
    var sounds = Events.impactSounds(snapshot({ impacts: [
      { kind: "rail", speed: 1 }, { kind: "sphere", speed: 3 }, { kind: "rail", speed: 2.5 }
    ] }))
    compare(sounds.length, 2)
    compare(sounds[0].name, "bounce")
    near(sounds[0].gain, 0.5)
    compare(sounds[1].name, "clack")
    near(sounds[1].gain, 0.375)
  }

  function test_impactSoundGainIsBounded() {
    var sounds = Events.impactSounds(snapshot({ impacts: [
      { kind: "rail", speed: 50 }, { kind: "sphere", speed: 0.01 }
    ] }))
    near(sounds[0].gain, 1)
    near(sounds[1].gain, 0.2)
  }

  function test_impactsAreSilentUnlessRunning() {
    compare(Events.impactSounds(null).length, 0)
    compare(Events.impactSounds(snapshot()).length, 0)
    compare(Events.impactSounds(snapshot({ status: "paused", impacts: [{ kind: "rail", speed: 2 }] })).length, 0)
  }

  function near(actual, expected) {
    verify(Math.abs(actual - expected) < 1e-9, actual + " != " + expected)
  }
}
