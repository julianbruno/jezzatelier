.pragma library

// Bundled offline collection in reference tour order. This file is the single source of
// truth for the catalog: scripts/build-media.sh reads it to fetch, verify, and encode media.

var artworks = [
  {
    id: "rubens-rainbow",
    title: "Landscape with a Rainbow",
    creator: "Peter Paul Rubens",
    date: "c. 1630–1635",
    license: "Public domain",
    sourceUrl: "https://commons.wikimedia.org/wiki/File:Rubens_Peter_Paul_-_Landscape_with_a_Rainbow.jpg",
    file: "assets/artworks/rubens-rainbow.jpg"
  },
  {
    id: "lorrain-harbour",
    title: "Harbour Scene at Sunset",
    creator: "Claude Lorrain",
    date: "1643",
    license: "Public domain",
    sourceUrl: "https://commons.wikimedia.org/wiki/File:Claude_Lorrain_(1604-5-82)_-_Harbour_Scene_at_Sunset_-_RCIN_401382_-_Royal_Collection.jpg",
    file: "assets/artworks/lorrain-harbour.jpg"
  },
  {
    id: "poelenburch-gods",
    title: "A Gathering of the Gods in the Clouds",
    creator: "Cornelis van Poelenburch",
    date: "1630s",
    license: "Public domain",
    sourceUrl: "https://commons.wikimedia.org/wiki/File:Meeting_Gods_In_The_Clouds_by_Cornelis_van_Poelenburch.jpg",
    file: "assets/artworks/poelenburch-gods.jpg"
  },
  {
    id: "rembrandt-night-watch",
    title: "The Night Watch",
    creator: "Rembrandt van Rijn",
    date: "1642",
    license: "Public domain",
    sourceUrl: "https://commons.wikimedia.org/wiki/File:The_Night_Watch.jpg",
    file: "assets/artworks/rembrandt-night-watch.jpg"
  },
  {
    id: "caravaggio-emmaus",
    title: "Supper at Emmaus",
    creator: "Caravaggio",
    date: "1601",
    license: "Public domain",
    sourceUrl: "https://commons.wikimedia.org/wiki/File:Supper_at_Emmaus-Caravaggio_(1601).jpg",
    file: "assets/artworks/caravaggio-emmaus.jpg"
  },
  {
    id: "vermeer-art-of-painting",
    title: "The Art of Painting",
    creator: "Johannes Vermeer",
    date: "c. 1666–1668",
    license: "Public domain",
    sourceUrl: "https://commons.wikimedia.org/wiki/File:Jan_Vermeer_-_The_Art_of_Painting_-_Google_Art_Project.jpg",
    file: "assets/artworks/vermeer-art-of-painting.jpg"
  },
  {
    id: "vermeer-delft",
    title: "View of Delft",
    creator: "Johannes Vermeer",
    date: "1660–1661",
    license: "Public domain",
    sourceUrl: "https://commons.wikimedia.org/wiki/File:View_of_Delft,_by_Johannes_Vermeer.jpg",
    file: "assets/artworks/vermeer-delft.jpg"
  },
  {
    id: "rubens-garden-love",
    title: "The Garden of Love",
    creator: "Peter Paul Rubens and Workshop",
    date: "c. 1640",
    license: "Public domain",
    sourceUrl: "https://commons.wikimedia.org/wiki/File:Peter_Paul_Rubens_and_Workshop_-_The_Garden_of_Love.jpg",
    file: "assets/artworks/rubens-garden-love.jpg"
  },
  {
    id: "velazquez-meninas",
    title: "Las Meninas",
    creator: "Diego Velázquez",
    date: "1656–1657",
    license: "Public domain",
    sourceUrl: "https://commons.wikimedia.org/wiki/File:Diego_Velázquez_-_Las_Meninas_or_The_Family_of_Philip_IV_-_WGA24448.jpg",
    file: "assets/artworks/velazquez-meninas.jpg"
  },
  {
    id: "rembrandt-storm",
    title: "The Storm on the Sea of Galilee",
    creator: "Rembrandt van Rijn",
    date: "1633",
    license: "Public domain",
    sourceUrl: "https://commons.wikimedia.org/wiki/File:Rembrandt_-_Christ_in_the_Storm_on_the_Sea_of_Galilee.jpeg",
    file: "assets/artworks/rembrandt-storm.jpg"
  }
]

var tracks = [
  {
    id: "bach-01",
    title: "Prelude No. 1 in C major, BWV 846",
    creator: "Johann Sebastian Bach — Kimiko Ishizaka",
    license: "CC0",
    sourceUrl: "https://commons.wikimedia.org/wiki/File:Kimiko_Ishizaka_-_Bach_-_Well-Tempered_Clavier,_Book_1_-_01_Prelude_No._1_in_C_major,_BWV_846.ogg",
    file: "assets/music/bach-01.opus"
  },
  {
    id: "bach-02",
    title: "Fugue No. 1 in C major, BWV 846",
    creator: "Johann Sebastian Bach — Kimiko Ishizaka",
    license: "CC0",
    sourceUrl: "https://commons.wikimedia.org/wiki/File:Kimiko_Ishizaka_-_Bach_-_Well-Tempered_Clavier,_Book_1_-_02_Fugue_No._1_in_C_major,_BWV_846.ogg",
    file: "assets/music/bach-02.opus"
  },
  {
    id: "bach-03",
    title: "Prelude No. 2 in C minor, BWV 847",
    creator: "Johann Sebastian Bach — Kimiko Ishizaka",
    license: "CC0",
    sourceUrl: "https://commons.wikimedia.org/wiki/File:Kimiko_Ishizaka_-_Bach_-_Well-Tempered_Clavier,_Book_1_-_03_Prelude_No._2_in_C_minor,_BWV_847.ogg",
    file: "assets/music/bach-03.opus"
  },
  {
    id: "bach-04",
    title: "Fugue No. 2 in C minor, BWV 847",
    creator: "Johann Sebastian Bach — Kimiko Ishizaka",
    license: "CC0",
    sourceUrl: "https://commons.wikimedia.org/wiki/File:Kimiko_Ishizaka_-_Bach_-_Well-Tempered_Clavier,_Book_1_-_04_Fugue_No._2_in_C_minor,_BWV_847.ogg",
    file: "assets/music/bach-04.opus"
  },
  {
    id: "bach-06",
    title: "Fugue No. 3 in C-sharp major, BWV 848",
    creator: "Johann Sebastian Bach — Kimiko Ishizaka",
    license: "CC0",
    sourceUrl: "https://commons.wikimedia.org/wiki/File:Kimiko_Ishizaka_-_Bach_-_Well-Tempered_Clavier,_Book_1_-_06_Fugue_No._3_in_C-sharp_major,_BWV_848.ogg",
    file: "assets/music/bach-06.opus"
  },
  {
    id: "bach-07",
    title: "Prelude No. 4 in C-sharp minor, BWV 849",
    creator: "Johann Sebastian Bach — Kimiko Ishizaka",
    license: "CC0",
    sourceUrl: "https://commons.wikimedia.org/wiki/File:Kimiko_Ishizaka_-_Bach_-_Well-Tempered_Clavier,_Book_1_-_07_Prelude_No._4_in_C-sharp_minor,_BWV_849.ogg",
    file: "assets/music/bach-07.opus"
  },
  {
    id: "bach-18",
    title: "Fugue No. 9 in E major, BWV 854",
    creator: "Johann Sebastian Bach — Kimiko Ishizaka",
    license: "CC0",
    sourceUrl: "https://commons.wikimedia.org/wiki/File:Kimiko_Ishizaka_-_Bach_-_Well-Tempered_Clavier,_Book_1_-_18_Fugue_No._9_in_E_major,_BWV_854.ogg",
    file: "assets/music/bach-18.opus"
  },
  {
    id: "bach-26",
    title: "Fugue No. 13 in F-sharp major, BWV 858",
    creator: "Johann Sebastian Bach — Kimiko Ishizaka",
    license: "CC0",
    sourceUrl: "https://commons.wikimedia.org/wiki/File:Kimiko_Ishizaka_-_Bach_-_Well-Tempered_Clavier,_Book_1_-_26_Fugue_No._13_in_F-sharp_major,_BWV_858.ogg",
    file: "assets/music/bach-26.opus"
  },
  {
    id: "bach-36",
    title: "Fugue No. 18 in G-sharp minor, BWV 863",
    creator: "Johann Sebastian Bach — Kimiko Ishizaka",
    license: "CC0",
    sourceUrl: "https://commons.wikimedia.org/wiki/File:Kimiko_Ishizaka_-_Bach_-_Well-Tempered_Clavier,_Book_1_-_36_Fugue_No._18_in_G-sharp_minor,_BWV_863.ogg",
    file: "assets/music/bach-36.opus"
  },
  {
    id: "bach-41",
    title: "Prelude No. 21 in B-flat major, BWV 866",
    creator: "Johann Sebastian Bach — Kimiko Ishizaka",
    license: "CC0",
    sourceUrl: "https://commons.wikimedia.org/wiki/File:Kimiko_Ishizaka_-_Bach_-_Well-Tempered_Clavier,_Book_1_-_41_Prelude_No._21_in_B-flat_major,_BWV_866.ogg",
    file: "assets/music/bach-41.opus"
  }
]

var sfx = {
  "build": "assets/sfx/build.wav",
  "capture": "assets/sfx/capture.wav",
  "life-lost": "assets/sfx/life-lost.wav",
  "level-clear": "assets/sfx/level-clear.wav",
  "game-over": "assets/sfx/game-over.wav"
}

function indexForWave(wave, count) {
  return ((Number.isSafeInteger(wave) && wave > 0 ? wave : 1) - 1) % count
}

function artworkById(id) {
  for (var i = 0; i < artworks.length; i++) {
    if (artworks[i].id === id) return artworks[i]
  }
  return null
}

// Tour mode cycles through the collection by wave; fixed mode keeps one painting.
function artworkForWave(wave, randomArtwork, artworkId) {
  if (randomArtwork) return artworks[indexForWave(wave, artworks.length)]
  return artworkById(artworkId) || artworks[0]
}

function trackForWave(wave) {
  return tracks[indexForWave(wave, tracks.length)]
}

function sfxFile(name) {
  return sfx[name] || null
}

if (typeof module !== "undefined") {
  module.exports = {
    artworks: artworks,
    tracks: tracks,
    sfx: sfx,
    artworkById: artworkById,
    artworkForWave: artworkForWave,
    trackForWave: trackForWave,
    sfxFile: sfxFile
  }
}
