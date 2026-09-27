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
}
