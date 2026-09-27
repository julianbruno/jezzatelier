.pragma library

// Derives presentation events (sounds, messages, flashes) from consecutive engine snapshots,
// so the overlay never needs hooks inside the pure engine.

// Event order follows construction, capture, damage, then terminal status.
function soundEvents(previous, next) {
  if (!previous || !next) return []

  var events = []
  if (!previous.growingWall && next.growingWall) events.push("build")
  if ((next.walls || []).length > (previous.walls || []).length) events.push("capture")
  if (next.lives < previous.lives) events.push("life-lost")
  if (next.status !== previous.status && next.status === "level-clear") events.push("level-clear")
  if (next.status !== previous.status && next.status === "game-over") events.push("game-over")
  return events
}

function livesLeftText(lives) {
  if (lives === 1) return "last life"
  return lives + " lives left"
}

// Short toast messages: { text, tone } with tone "gain", "loss", or "info".
function feedback(previous, next) {
  if (!previous || !next) return []

  var messages = []
  if (next.walls.length > previous.walls.length) {
    var points = Math.round((next.coverage - previous.coverage) * 10000)
    if (points > 0)
      messages.push({ tone: "gain", text: "+" + points + " · " + Math.round(next.coverage * 100) + "% claimed" })
    else
      messages.push({ tone: "info", text: "Wall built · nothing enclosed" })
  }
  if (next.lives < previous.lives && next.lives > 0) {
    messages.push({ tone: "loss", text: "Wall broken · " + livesLeftText(next.lives) })
  }
  if (next.playerCount === 2 && next.activePlayer !== previous.activePlayer && next.status === "running") {
    messages.push({ tone: "info", text: "Player " + (next.activePlayer + 1) + "'s turn" })
  }
  return messages
}

// Why placeWall refused a spot, given the game snapshot and its previewWall result.
function placementRejection(snapshot, preview) {
  if (snapshot.growingWall) return "One wall at a time"
  if (preview.regionId === null) return "That space is already claimed"
  return "Too close to a sphere or an edge"
}

function newlyClaimed(previous, next) {
  if (!previous || !next) return []

  var known = {}
  previous.regions.forEach(function(region) {
    if (region.claimed) known[region.id] = true
  })
  return next.regions.filter(function(region) { return region.claimed && !known[region.id] })
}

if (typeof module !== "undefined") {
  module.exports = {
    soundEvents: soundEvents,
    feedback: feedback,
    placementRejection: placementRejection,
    newlyClaimed: newlyClaimed
  }
}
