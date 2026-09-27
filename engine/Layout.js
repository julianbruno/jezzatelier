.pragma library

// Geometry between world units (16 × 10 field) and pixels inside a letterboxed box.

var WORLD_WIDTH = 16
var WORLD_HEIGHT = 10
var ASPECT = WORLD_WIDTH / WORLD_HEIGHT

function fit(width, height) {
  var boxWidth = Math.min(width, height * ASPECT)
  var boxHeight = boxWidth / ASPECT
  return { x: (width - boxWidth) / 2, y: (height - boxHeight) / 2, width: boxWidth, height: boxHeight }
}

function toPixel(box, x, y) {
  return { x: box.x + x * box.width / WORLD_WIDTH, y: box.y + y * box.height / WORLD_HEIGHT }
}

function toWorld(box, x, y) {
  return { x: (x - box.x) * WORLD_WIDTH / box.width, y: (y - box.y) * WORLD_HEIGHT / box.height }
}

// Pixel rectangle for a wall segment centered on `fixed`, spanning `from`..`to`
// along its own axis, with a thickness given in world units.
function segmentRect(box, orientation, fixed, from, to, thickness) {
  var unit = box.width / WORLD_WIDTH
  var start = orientation === "vertical" ? toPixel(box, fixed, from) : toPixel(box, from, fixed)
  var end = orientation === "vertical" ? toPixel(box, fixed, to) : toPixel(box, to, fixed)
  var size = thickness * unit

  if (orientation === "vertical")
    return { x: start.x - size / 2, y: start.y, width: size, height: end.y - start.y }
  return { x: start.x, y: start.y - size / 2, width: end.x - start.x, height: size }
}

if (typeof module !== "undefined") {
  module.exports = { fit: fit, toPixel: toPixel, toWorld: toWorld, segmentRect: segmentRect }
}
