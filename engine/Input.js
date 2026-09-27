.pragma library

function action(key, modifiers) {
  if (key === Qt.Key_Left || key === Qt.Key_Right || key === Qt.Key_Up || key === Qt.Key_Down) return "move"
  if (key === Qt.Key_Space || key === Qt.Key_Return || key === Qt.Key_Enter) return "place"
  if (key === Qt.Key_R) return "rotate"
  if (key === Qt.Key_P) return "pause"
  if (key === Qt.Key_Escape) return "escape"
  return ""
}

function move(cursor, key, modifiers) {
  var step = modifiers & Qt.ShiftModifier ? 1 : 0.4
  var x = cursor.x + (key === Qt.Key_Right ? step : key === Qt.Key_Left ? -step : 0)
  var y = cursor.y + (key === Qt.Key_Down ? step : key === Qt.Key_Up ? -step : 0)
  return {x: Math.max(0.1, Math.min(15.9, x)), y: Math.max(0.1, Math.min(9.9, y))}
}

if (typeof module !== "undefined") module.exports = {action: action, move: move}
