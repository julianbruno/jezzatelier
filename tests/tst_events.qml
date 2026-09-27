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
}
