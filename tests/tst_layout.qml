import QtQuick
import QtTest
import "../engine/Layout.js" as Layout

TestCase {
  name: "Layout"
  function test_fit() {
    var wide = Layout.fit(1600, 600)
    compare(wide.width, 960)
    compare(wide.x, 320)
    var tall = Layout.fit(600, 1000)
    compare(tall.width, 600)
    compare(tall.height, 375)
    compare(tall.y, 312.5)
  }
  function test_roundTrip() {
    var box = Layout.fit(800, 700)
    var pixel = Layout.toPixel(box, 3.2, 7.4)
    var world = Layout.toWorld(box, pixel.x, pixel.y)
    verify(Math.abs(world.x - 3.2) < 0.00001)
    verify(Math.abs(world.y - 7.4) < 0.00001)
  }

  function test_segmentRect() {
    var box = { x: 10, y: 20, width: 160, height: 100 }
    var vertical = Layout.segmentRect(box, "vertical", 4, 2, 6, 0.2)
    compare(vertical.x, 49)
    compare(vertical.y, 40)
    compare(vertical.width, 2)
    compare(vertical.height, 40)

    var horizontal = Layout.segmentRect(box, "horizontal", 5, 1, 9, 0.2)
    compare(horizontal.x, 20)
    compare(horizontal.y, 69)
    compare(horizontal.width, 80)
    compare(horizontal.height, 2)
  }
}
