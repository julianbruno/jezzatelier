import QtQuick
import QtTest
import "../engine/Input.js" as Input

TestCase {
  name: "Input"
  function test_actions() {
    compare(Input.action(Qt.Key_R, 0), "rotate")
    compare(Input.action(Qt.Key_P, 0), "pause")
    compare(Input.action(Qt.Key_Space, 0), "place")
    compare(Input.action(Qt.Key_Return, 0), "place")
    compare(Input.action(Qt.Key_Escape, 0), "escape")
    compare(Input.action(Qt.Key_A, 0), "")
  }
  function test_cursor() {
    compare(Input.move({x: 8, y: 5}, Qt.Key_Left, 0).x, 7.6)
    compare(Input.move({x: 8, y: 5}, Qt.Key_Down, Qt.ShiftModifier).y, 6)
    compare(Input.move({x: 0.1, y: 9.9}, Qt.Key_Left, 0).x, 0.1)
    compare(Input.move({x: 0.1, y: 9.9}, Qt.Key_Down, 0).y, 9.9)
  }
}
