.pragma library

// Pure game rules for Jezz Atelier. Behavior is specified in odd/specs/engine-rules.md.
// State is a plain JSON-safe object so the overlay can render and persist it directly.

var WIDTH = 16
var HEIGHT = 10
var SPHERE_RADIUS = 0.28
var CLEARANCE = 0.09
var WALL_SPEED = 7.5
var MAX_STEP = 0.05
var TICK = 1 / 120
var MAX_TICKS_PER_FRAME = 30
var MAX_FRAME_TIME = 30
var DEFAULT_SEED = 0x6d2b79f5

var DIFFICULTIES = ["relaxed", "classic", "expert"]

function profile(wave, difficulty) {
  var n = Math.max(0, Math.floor(wave) - 1)
  var tier = Math.floor(n / 3)

  if (difficulty === "relaxed") {
    return {
      spheres: Math.min(6, 2 + tier),
      speedScale: 0.75 + Math.min(0.25, 0.02 * n),
      targetCoverage: 0.65 + Math.min(0.07, 0.01 * tier),
      timeLimit: Math.max(120, 150 - 2 * n),
      lives: 5
    }
  }

  if (difficulty === "expert") {
    return {
      spheres: Math.min(9, 4 + n),
      speedScale: 1.15 + Math.min(0.35, 0.03 * n),
      targetCoverage: 0.78 + Math.min(0.04, 0.005 * tier),
      timeLimit: Math.max(80, 100 - 2 * n),
      lives: 3
    }
  }

  return {
    spheres: Math.min(9, 3 + n),
    speedScale: 1 + Math.min(0.30, 0.025 * n),
    targetCoverage: 0.75 + Math.min(0.03, 0.005 * tier),
    timeLimit: Math.max(90, 105 - 2 * n),
    lives: 3
  }
}

function normalizedDifficulty(difficulty) {
  return DIFFICULTIES.indexOf(difficulty) === -1 ? "classic" : difficulty
}

// xorshift32: small, fast, and reproducible from the stored state alone.
function random(game) {
  var x = game.rngState >>> 0
  x ^= x << 13
  x ^= x >>> 17
  x ^= x << 5
  game.rngState = x >>> 0
  return game.rngState / 4294967296
}

function between(game, min, max) {
  return min + (max - min) * random(game)
}

function isSeparated(spheres, x, y) {
  return spheres.every(function(other) {
    return Math.hypot(other.x - x, other.y - y) > 3 * SPHERE_RADIUS
  })
}

function spawnSpheres(game, waveProfile) {
  var margin = SPHERE_RADIUS + 0.6
  game.spheres = []

  for (var i = 0; i < waveProfile.spheres; i++) {
    var x = 0
    var y = 0
    for (var attempt = 0; attempt < 40; attempt++) {
      x = between(game, margin, WIDTH - margin)
      y = between(game, margin, HEIGHT - margin)
      if (isSeparated(game.spheres, x, y)) break
    }

    var angle = between(game, 0, 2 * Math.PI)
    var speed = between(game, 2.2, 3.1) * game.globalSpeedScale * waveProfile.speedScale
    game.spheres.push({
      id: i + 1,
      regionId: 1,
      x: x,
      y: y,
      vx: Math.cos(angle) * speed,
      vy: Math.sin(angle) * speed,
      radius: SPHERE_RADIUS
    })
  }
}

function resetField(game) {
  var waveProfile = profile(game.wave, game.difficulty)
  game.targetCoverage = waveProfile.targetCoverage
  game.timeRemaining = waveProfile.timeLimit
  game.coverage = 0
  game.lastBonus = 0
  game.walls = []
  game.growingWall = null
  game.regions = [{ id: 1, minX: 0, maxX: WIDTH, minY: 0, maxY: HEIGHT, claimed: false }]
  game.nextRegionId = 2
  game.nextWallId = 1
  spawnSpheres(game, waveProfile)
}

function reset(game, seed, playerCount, difficulty) {
  game.seed = (seed >>> 0) || DEFAULT_SEED
  game.rngState = game.seed
  game.playerCount = playerCount === 2 ? 2 : 1
  game.difficulty = normalizedDifficulty(difficulty)
  game.wave = 1
  game.status = "ready"
  game.orientation = "vertical"
  game.activePlayer = 0
  game.score = 0
  game.playerScores = game.playerCount === 2 ? [0, 0] : [0]
  game.lives = profile(1, game.difficulty).lives
  resetField(game)
  return game
}

function createGame(seed, options) {
  options = options || {}
  var game = {
    globalSpeedScale: options.globalSpeedScale === undefined ? 1 : options.globalSpeedScale
  }
  return reset(game, seed, options.playerCount, options.difficulty)
}

function start(game) {
  if (game.status === "ready") game.status = "running"
}

function togglePause(game) {
  if (game.status === "running") game.status = "paused"
  else if (game.status === "paused") game.status = "running"
}

function toggleOrientation(game) {
  game.orientation = game.orientation === "vertical" ? "horizontal" : "vertical"
}

function openRegionAt(game, x, y) {
  for (var i = 0; i < game.regions.length; i++) {
    var region = game.regions[i]
    if (!region.claimed
        && x > region.minX + CLEARANCE && x < region.maxX - CLEARANCE
        && y > region.minY + CLEARANCE && y < region.maxY - CLEARANCE)
      return region
  }
  return null
}

function isNearSphere(game, region, x, y) {
  return game.spheres.some(function(sphere) {
    return sphere.regionId === region.id
      && Math.hypot(sphere.x - x, sphere.y - y) <= sphere.radius + CLEARANCE
  })
}

// Describes the wall that placeWall(x, y) would start, without mutating the game.
function previewWall(game, x, y) {
  var region = openRegionAt(game, x, y)
  var vertical = game.orientation === "vertical"
  var valid = game.status === "running" && !game.growingWall
    && region !== null && !isNearSphere(game, region, x, y)

  return {
    valid: valid,
    regionId: region ? region.id : null,
    orientation: game.orientation,
    x: x,
    y: y,
    negativeLimit: region ? (vertical ? region.minY : region.minX) : null,
    positiveLimit: region ? (vertical ? region.maxY : region.maxX) : null
  }
}

function placeWall(game, x, y) {
  var preview = previewWall(game, x, y)
  if (!preview.valid) return false

  var anchor = preview.orientation === "vertical" ? y : x
  game.growingWall = {
    id: game.nextWallId++,
    regionId: preview.regionId,
    orientation: preview.orientation,
    x: x,
    y: y,
    negativeEnd: anchor,
    positiveEnd: anchor,
    negativeLimit: preview.negativeLimit,
    positiveLimit: preview.positiveLimit
  }
  return true
}

function advanceTurn(game) {
  if (game.playerCount === 2) game.activePlayer = 1 - game.activePlayer
}

function award(game, points) {
  game.score += points
  game.playerScores[game.activePlayer] += points
}

function isWallTouched(game, wall) {
  return game.spheres.some(function(sphere) {
    if (sphere.regionId !== wall.regionId) return false
    var reach = sphere.radius + CLEARANCE
    if (wall.orientation === "vertical")
      return Math.abs(sphere.x - wall.x) <= reach
        && sphere.y + sphere.radius >= wall.negativeEnd
        && sphere.y - sphere.radius <= wall.positiveEnd
    return Math.abs(sphere.y - wall.y) <= reach
      && sphere.x + sphere.radius >= wall.negativeEnd
      && sphere.x - sphere.radius <= wall.positiveEnd
  })
}

function claimedArea(game) {
  return game.regions.reduce(function(sum, region) {
    return region.claimed ? sum + (region.maxX - region.minX) * (region.maxY - region.minY) : sum
  }, 0)
}

function updateCoverage(game) {
  var previous = game.coverage
  game.coverage = claimedArea(game) / (WIDTH * HEIGHT)
  award(game, Math.max(0, Math.round((game.coverage - previous) * 10000)))

  if (game.coverage >= game.targetCoverage) {
    game.lastBonus = Math.round(game.timeRemaining * 25 + game.lives * 250)
    award(game, game.lastBonus)
    game.status = "level-clear"
  }
}

// Replaces the wall's region with the two halves it separates; empty halves are claimed.
function completeWall(game, wall) {
  var index = game.regions.findIndex(function(region) { return region.id === wall.regionId })
  var parent = game.regions[index]
  var vertical = wall.orientation === "vertical"
  var first = { id: game.nextRegionId++, minX: parent.minX, maxX: parent.maxX, minY: parent.minY, maxY: parent.maxY, claimed: false }
  var second = { id: game.nextRegionId++, minX: parent.minX, maxX: parent.maxX, minY: parent.minY, maxY: parent.maxY, claimed: false }
  if (vertical) {
    first.maxX = wall.x
    second.minX = wall.x
  } else {
    first.maxY = wall.y
    second.minY = wall.y
  }

  var firstOccupied = false
  var secondOccupied = false
  game.spheres.forEach(function(sphere) {
    if (sphere.regionId !== parent.id) return
    var inFirst = vertical ? sphere.x <= wall.x : sphere.y <= wall.y
    sphere.regionId = inFirst ? first.id : second.id
    if (inFirst) firstOccupied = true
    else secondOccupied = true
  })
  first.claimed = !firstOccupied
  second.claimed = !secondOccupied

  game.regions.splice(index, 1, first, second)
  game.walls.push(wall)
  game.growingWall = null
  updateCoverage(game)
  advanceTurn(game)
}

function breakWall(game) {
  game.growingWall = null
  game.lives--
  advanceTurn(game)
  if (game.lives <= 0) game.status = "game-over"
}

function growWall(game, dt) {
  var wall = game.growingWall
  if (!wall) return

  wall.negativeEnd = Math.max(wall.negativeLimit, wall.negativeEnd - WALL_SPEED * dt)
  wall.positiveEnd = Math.min(wall.positiveLimit, wall.positiveEnd + WALL_SPEED * dt)

  if (isWallTouched(game, wall)) breakWall(game)
  else if (wall.negativeEnd === wall.negativeLimit && wall.positiveEnd === wall.positiveLimit)
    completeWall(game, wall)
}

function regionOf(game, sphere) {
  return game.regions.find(function(candidate) { return candidate.id === sphere.regionId })
}

// Clamps a sphere inside its region and turns its velocity back inward at each edge.
function keepInsideRegion(sphere, region) {
  if (sphere.x < region.minX + sphere.radius) {
    sphere.x = region.minX + sphere.radius
    sphere.vx = Math.abs(sphere.vx)
  } else if (sphere.x > region.maxX - sphere.radius) {
    sphere.x = region.maxX - sphere.radius
    sphere.vx = -Math.abs(sphere.vx)
  }

  if (sphere.y < region.minY + sphere.radius) {
    sphere.y = region.minY + sphere.radius
    sphere.vy = Math.abs(sphere.vy)
  } else if (sphere.y > region.maxY - sphere.radius) {
    sphere.y = region.maxY - sphere.radius
    sphere.vy = -Math.abs(sphere.vy)
  }
}

// Equal-mass elastic collision: overlapping spheres are pushed apart along the line
// between their centers and, if approaching, exchange their velocity along that line.
function collidePair(a, b) {
  var dx = b.x - a.x
  var dy = b.y - a.y
  var distance = Math.hypot(dx, dy)
  var contact = a.radius + b.radius
  if (distance >= contact) return false

  var nx = distance > 0 ? dx / distance : 1
  var ny = distance > 0 ? dy / distance : 0
  var push = (contact - distance) / 2
  a.x -= nx * push
  a.y -= ny * push
  b.x += nx * push
  b.y += ny * push

  var approach = (b.vx - a.vx) * nx + (b.vy - a.vy) * ny
  if (approach < 0) {
    a.vx += approach * nx
    a.vy += approach * ny
    b.vx -= approach * nx
    b.vy -= approach * ny
  }
  return true
}

function collideSpheres(game) {
  var spheres = game.spheres
  for (var i = 0; i < spheres.length; i++) {
    for (var j = i + 1; j < spheres.length; j++) {
      var a = spheres[i]
      var b = spheres[j]
      if (a.regionId !== b.regionId || !collidePair(a, b)) continue
      var region = regionOf(game, a)
      keepInsideRegion(a, region)
      keepInsideRegion(b, region)
    }
  }
}

function moveSpheres(game, dt) {
  game.spheres.forEach(function(sphere) {
    sphere.x += sphere.vx * dt
    sphere.y += sphere.vy * dt
    keepInsideRegion(sphere, regionOf(game, sphere))
  })
  collideSpheres(game)
}

function elapseTime(game, dt) {
  if (game.status !== "running") return
  game.timeRemaining = Math.max(0, game.timeRemaining - Math.max(0, dt))
  if (game.timeRemaining === 0) game.status = "game-over"
}

function step(game, dt, options) {
  if (game.status !== "running") return
  dt = Math.max(0, Math.min(MAX_STEP, dt))

  if (!options || options.advanceClock !== false) elapseTime(game, dt)
  if (game.status !== "running") return

  growWall(game, dt)
  if (game.status === "running") moveSpheres(game, dt)
}

// Fixed-step driver for the render loop: the clock elapses once per frame, the
// simulation advances in 1/120 s ticks, and the leftover time is carried in `clock`.
function advanceFrame(game, clock, frameTime) {
  var elapsed = Math.min(MAX_FRAME_TIME, Math.max(0, frameTime))
  elapseTime(game, elapsed)

  var available = Math.max(0, clock.remainder || 0) + elapsed
  var ticks = 0
  while (available >= TICK && ticks < MAX_TICKS_PER_FRAME) {
    step(game, TICK, { advanceClock: false })
    available -= TICK
    ticks++
  }

  clock.remainder = Math.min(TICK, Math.max(0, available))
  return clock.remainder
}

function nextLevel(game) {
  if (game.status !== "level-clear") return false
  game.wave++
  resetField(game)
  game.status = "running"
  return true
}

function snapshot(game) {
  return JSON.parse(JSON.stringify(game))
}

if (typeof module !== "undefined") {
  module.exports = {
    WIDTH: WIDTH,
    HEIGHT: HEIGHT,
    DIFFICULTIES: DIFFICULTIES,
    profile: profile,
    createGame: createGame,
    reset: reset,
    start: start,
    togglePause: togglePause,
    toggleOrientation: toggleOrientation,
    previewWall: previewWall,
    placeWall: placeWall,
    step: step,
    elapseTime: elapseTime,
    advanceFrame: advanceFrame,
    nextLevel: nextLevel,
    snapshot: snapshot
  }
}
