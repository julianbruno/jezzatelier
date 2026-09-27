.pragma library

// Event order follows construction, capture, damage, then terminal status.
function soundEvents(previousSnapshot, nextSnapshot) {
  if (!previousSnapshot || !nextSnapshot) return []
  var events = []
  if (!previousSnapshot.growingWall && nextSnapshot.growingWall) events.push("build")
  if ((nextSnapshot.walls || []).length > (previousSnapshot.walls || []).length) events.push("capture")
  if (nextSnapshot.lives < previousSnapshot.lives) events.push("life-lost")
  if (nextSnapshot.status !== previousSnapshot.status && nextSnapshot.status === "level-clear")
    events.push("level-clear")
  if (nextSnapshot.status !== previousSnapshot.status && nextSnapshot.status === "game-over")
    events.push("game-over")
  return events
}

if (typeof module !== "undefined") module.exports = { soundEvents: soundEvents }
