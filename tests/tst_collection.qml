import QtQuick
import QtTest
import "../engine/Collection.js" as Collection

TestCase {
  name: "Collection"
  when: windowShown
  Image { id: inventoryImage; visible: false }

  function test_catalog() {
    compare(Collection.artworks.length, 10)
    compare(Collection.tracks.length, 10)
    compare(Object.keys(Collection.sfx).length, 7)
    var ids = {}
    var entries = Collection.artworks.concat(Collection.tracks)
    for (var i = 0; i < entries.length; i++) {
      var entry = entries[i]
      verify(entry.id && entry.title && entry.creator && entry.file && entry.license)
      verify(!ids[entry.id])
      ids[entry.id] = true
      verify(/^(Public Domain|PD|CC0)/i.test(entry.license))
      verify(entry.sourceUrl.indexOf("https://commons.wikimedia.org/wiki/File:") === 0, entry.id)
    }
  }

  function test_waveAndFixedSelection() {
    compare(Collection.artworkForWave(1, true).id, Collection.artworks[0].id)
    compare(Collection.artworkForWave(10, true).id, Collection.artworks[9].id)
    compare(Collection.artworkForWave(11, true).id, Collection.artworks[0].id)
    compare(Collection.trackForWave(11).id, Collection.tracks[0].id)
    for (var wave of [0, -1, NaN]) {
      compare(Collection.artworkForWave(wave, true).id, Collection.artworks[0].id)
      compare(Collection.trackForWave(wave).id, Collection.tracks[0].id)
    }
    compare(Collection.artworkForWave(3, false, Collection.artworks[4].id).id, Collection.artworks[4].id)
    compare(Collection.artworkForWave(3, false, "unknown").id, Collection.artworks[0].id)
    compare(Collection.artworkById("unknown"), null)
    verify(Collection.sfxFile("build").endsWith("build.wav"))
    verify(Collection.sfxFile("bounce").endsWith("bounce.wav"))
    verify(Collection.sfxFile("clack").endsWith("clack.wav"))
  }

  function test_inventoryImages() {
    for (var i = 0; i < Collection.artworks.length; i++) {
      inventoryImage.source = Qt.resolvedUrl("../" + Collection.artworks[i].file)
      tryCompare(inventoryImage, "status", Image.Ready, 10000)
      verify(inventoryImage.sourceSize.width > 0 && inventoryImage.sourceSize.height > 0)
    }
  }
}
