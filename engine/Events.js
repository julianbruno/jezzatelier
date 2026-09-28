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

// Collision sounds for one frame: the strongest rail hit and the strongest sphere hit,
// each with a gain that grows with impact speed. Rails are struck at up to one sphere
// speed, pairs close at up to twice that, hence the different full-scale speeds.
var IMPACT_SOUNDS = {
  rail: { name: "bounce", fullSpeed: 5 },
  sphere: { name: "clack", fullSpeed: 8 }
}
var MIN_IMPACT_GAIN = 0.2

function impactSounds(snapshot) {
  if (!snapshot || snapshot.status !== "running") return []

  var strongest = {}
  ;(snapshot.impacts || []).forEach(function(impact) {
    if (IMPACT_SOUNDS[impact.kind] && (!strongest[impact.kind] || impact.speed > strongest[impact.kind]))
      strongest[impact.kind] = impact.speed
  })
  return ["rail", "sphere"].filter(function(kind) { return strongest[kind] }).map(function(kind) {
    var sound = IMPACT_SOUNDS[kind]
    var gain = Math.min(1, Math.max(MIN_IMPACT_GAIN, strongest[kind] / sound.fullSpeed))
    return { name: sound.name, gain: gain }
  })
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
    impactSounds: impactSounds,
    feedback: feedback,
    placementRejection: placementRejection,
    newlyClaimed: newlyClaimed
  }
}
