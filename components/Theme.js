.pragma library

// Shared atelier palette: near-black green surfaces, ivory text, gold actions, cyan focus.

var ink = "#101b17"
var surface = "#1a2b24"
var control = "#1c2c25"
var controlHover = "#31463d"
var controlSelected = "#6b5a34"
var ivory = "#f5eedb"
var gold = "#c8ad72"
var goldBright = "#e7cc92"
var wall = "#e6c584"
var focus = "#6de3e5"
var danger = "#ec827d"
var serif = "serif"

// Lacquered sphere colors, cycled by sphere id.
var sphereTints = ["#e67049", "#f0c66d", "#6bc2ba", "#8fa9d3", "#d57ba2", "#90bd62", "#e18d55", "#b09bda", "#71abc0"]

function sphereTint(id) {
  return sphereTints[(Math.max(1, id) - 1) % sphereTints.length]
}
