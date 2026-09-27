.pragma library
.import "Collection.js" as Collection

// Local state schema (preferences and high scores) with defensive sanitization, so a
// missing, corrupt, or hand-edited state file always degrades to safe defaults.

var STATE_VERSION = 1
var DIFFICULTIES = ["relaxed", "classic", "expert"]
var DEFAULT_SCORE_LIMIT = 10

function defaultPreferences() {
  return {
    difficulty: "classic",
    playerCount: 1,
    randomArtwork: true,
    artworkId: Collection.artworks[0].id,
    brightness: 82,
    musicVolume: 0.6,
    sfxVolume: 0.8,
    reducedMotion: false
  }
}

function isPlainObject(value) {
  return value !== null && typeof value === "object" && !Array.isArray(value)
}

function clamp(value, fallback, min, max) {
  if (typeof value !== "number" || !Number.isFinite(value)) return fallback
  return Math.max(min, Math.min(max, value))
}

function sanitizePreferences(raw) {
  var result = defaultPreferences()
  if (!isPlainObject(raw)) return result

  if (DIFFICULTIES.indexOf(raw.difficulty) !== -1) result.difficulty = raw.difficulty
  if (raw.playerCount === 1 || raw.playerCount === 2) result.playerCount = raw.playerCount
  if (Collection.artworkById(raw.artworkId)) result.artworkId = raw.artworkId
  if (typeof raw.randomArtwork === "boolean") result.randomArtwork = raw.randomArtwork
  if (typeof raw.reducedMotion === "boolean") result.reducedMotion = raw.reducedMotion
  result.brightness = clamp(raw.brightness, result.brightness, 45, 100)
  result.musicVolume = clamp(raw.musicVolume, result.musicVolume, 0, 1)
  result.sfxVolume = clamp(raw.sfxVolume, result.sfxVolume, 0, 1)
  return result
}

function isNonNegative(value) {
  return Number.isFinite(value) && value >= 0
}

function isValidScoreEntry(entry) {
  return isPlainObject(entry)
    && isNonNegative(entry.score)
    && Number.isSafeInteger(entry.wave) && entry.wave >= 1
    && DIFFICULTIES.indexOf(entry.difficulty) !== -1
    && (entry.playerCount === 1 || entry.playerCount === 2)
    && Array.isArray(entry.playerScores)
    && entry.playerScores.length === entry.playerCount
    && entry.playerScores.every(isNonNegative)
    && typeof entry.date === "string" && /^\d{4}-\d{2}-\d{2}/.test(entry.date)
}

function cleanEntry(entry) {
  if (!isValidScoreEntry(entry)) return null
  return {
    score: entry.score,
    wave: entry.wave,
    difficulty: entry.difficulty,
    playerCount: entry.playerCount,
    playerScores: entry.playerScores.slice(),
    date: entry.date
  }
}

// Higher score first, then further wave, then the earlier achievement.
function compareScores(a, b) {
  return b.score - a.score || b.wave - a.wave || a.date.localeCompare(b.date)
}

// Returns the sanitized, sorted, capped list and the 1-based rank of `entry`
// (0 when it is invalid or does not make the list).
function insertHighScore(scores, entry, limit) {
  var cap = limit === undefined ? DEFAULT_SCORE_LIMIT : Math.max(0, Math.floor(limit))
  var valid = (Array.isArray(scores) ? scores : [])
    .map(cleanEntry)
    .filter(function(item) { return item !== null })
  var candidate = cleanEntry(entry)
  if (candidate) valid.push(candidate)
  valid.sort(compareScores)

  var rank = candidate ? valid.indexOf(candidate) + 1 : 0
  return { scores: valid.slice(0, cap), rank: rank <= cap ? rank : 0 }
}

function normalizedState(raw) {
  var source = isPlainObject(raw) ? raw : {}
  return {
    version: STATE_VERSION,
    preferences: sanitizePreferences(source.preferences),
    highScores: insertHighScore(source.highScores, null).scores
  }
}

function parseState(text) {
  var raw = null
  try {
    raw = JSON.parse(text)
  } catch (error) {
    raw = null
  }
  return normalizedState(raw)
}

function serializeState(state) {
  return JSON.stringify(normalizedState(state), null, 2)
}

if (typeof module !== "undefined") {
  module.exports = {
    defaultPreferences: defaultPreferences,
    sanitizePreferences: sanitizePreferences,
    insertHighScore: insertHighScore,
    parseState: parseState,
    serializeState: serializeState
  }
}
