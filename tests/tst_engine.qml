import QtQuick
import QtTest
import "../engine/Engine.js" as Engine

TestCase {
  name: "Engine"

  function near(actual, expected) {
    verify(Math.abs(actual - expected) < 0.000001, actual + " != " + expected)
  }

  function runningGame(playerCount) {
    var game = Engine.createGame(123, { playerCount: playerCount || 1 })
    Engine.start(game)
    return game
  }

  function stillSphere(x, y) {
    return { id: 1, regionId: 1, x: x, y: y, vx: 0, vy: 0, radius: 0.28 }
  }

  function growUntilResolved(game) {
    for (var i = 0; i < 20 && game.growingWall; i++)
      Engine.step(game, 0.05, { advanceClock: false })
  }

  function test_profiles() {
    var waves = [1, 4, 100]
    var expected = {
      relaxed: { spheres: [2, 3, 6], speed: [0.75, 0.81, 1], target: [0.65, 0.66, 0.72], time: [150, 144, 120], lives: 5 },
      classic: { spheres: [3, 6, 9], speed: [1, 1.075, 1.3], target: [0.75, 0.755, 0.78], time: [105, 99, 90], lives: 3 },
      expert: { spheres: [4, 7, 9], speed: [1.15, 1.24, 1.5], target: [0.78, 0.785, 0.82], time: [100, 94, 80], lives: 3 }
    }

    for (var name in expected) {
      for (var i = 0; i < waves.length; i++) {
        var profile = Engine.profile(waves[i], name)
        compare(profile.spheres, expected[name].spheres[i])
        near(profile.speedScale, expected[name].speed[i])
        near(profile.targetCoverage, expected[name].target[i])
        compare(profile.timeLimit, expected[name].time[i])
        compare(profile.lives, expected[name].lives)
      }
    }

    compare(Engine.profile(1, "unknown").spheres, 3)
    compare(Engine.createGame(1, { difficulty: "unknown" }).difficulty, "classic")
  }

  function test_seed_and_spawn() {
    var first = Engine.createGame(12)
    var same = Engine.createGame(12)
    var other = Engine.createGame(13)
    compare(JSON.stringify(Engine.snapshot(first)), JSON.stringify(Engine.snapshot(same)))
    verify(JSON.stringify(Engine.snapshot(first)) !== JSON.stringify(Engine.snapshot(other)))

    for (var i = 0; i < first.spheres.length; i++) {
      var sphere = first.spheres[i]
      verify(sphere.x >= 0.88 && sphere.x <= 15.12 && sphere.y >= 0.88 && sphere.y <= 9.12)
      for (var j = 0; j < i; j++)
        verify(Math.hypot(sphere.x - first.spheres[j].x, sphere.y - first.spheres[j].y) > 0.84)
    }

    var copy = Engine.snapshot(first)
    copy.spheres[0].x = 999
    verify(first.spheres[0].x !== 999)
  }

  function test_status_and_time() {
    var game = Engine.createGame(1)
    var before = JSON.stringify(game)
    Engine.step(game, 0.01)
    compare(JSON.stringify(game), before)

    Engine.togglePause(game)
    compare(game.status, "ready")
    verify(!Engine.nextLevel(game))
    compare(game.wave, 1)

    Engine.start(game)
    Engine.start(game)
    compare(game.status, "running")

    Engine.togglePause(game)
    compare(game.status, "paused")
    Engine.step(game, 1)
    compare(game.timeRemaining, 105)

    Engine.togglePause(game)
    game.timeRemaining = 0.01
    var x = game.spheres[0].x
    Engine.step(game, 0.05)
    compare(game.status, "game-over")
    compare(game.timeRemaining, 0)
    compare(game.spheres[0].x, x)

    Engine.start(game)
    compare(game.status, "game-over")
  }

  function test_placement_and_preview() {
    var game = runningGame()
    game.spheres = [stillSphere(8, 5)]

    game.status = "paused"
    verify(!Engine.placeWall(game, 4, 4))
    game.status = "running"
    verify(!Engine.placeWall(game, 0.09, 4))
    verify(!Engine.placeWall(game, 8.3, 5))

    var before = JSON.stringify(game)
    verify(Engine.previewWall(game, 4, 4).valid)
    compare(JSON.stringify(game), before)

    verify(Engine.placeWall(game, 4, 4))
    verify(!Engine.placeWall(game, 6, 4))

    game.growingWall = null
    game.regions[0].claimed = true
    verify(!Engine.placeWall(game, 4, 4))
  }

  function test_growth_claim_score_and_turn() {
    var game = runningGame(2)
    game.spheres = [stillSphere(12, 5)]

    verify(Engine.placeWall(game, 8, 5))
    Engine.step(game, 0.05)
    near(game.growingWall.negativeEnd, 4.625)
    near(game.growingWall.positiveEnd, 5.375)

    growUntilResolved(game)
    compare(game.growingWall, null)
    compare(game.regions.length, 2)
    compare(game.spheres[0].regionId, game.regions[1].id)
    verify(game.regions[0].claimed)
    near(game.coverage, 0.5)
    compare(game.score, 5000)
    compare(game.playerScores[0], 5000)
    compare(game.activePlayer, 1)
    compare(game.walls.length, 1)
  }

  function test_break_and_game_over() {
    var game = runningGame(2)
    game.spheres = [{ id: 1, regionId: 1, x: 8, y: 5.6, vx: 0, vy: -4, radius: 0.28 }]

    verify(Engine.placeWall(game, 8, 5))
    Engine.step(game, 0.05)
    compare(game.growingWall, null)
    compare(game.walls.length, 0)
    compare(game.lives, 2)
    compare(game.activePlayer, 1)

    game.lives = 1
    game.spheres[0].y = 5.6
    verify(Engine.placeWall(game, 8, 5))
    Engine.step(game, 0.05)
    compare(game.lives, 0)
    compare(game.status, "game-over")
    compare(game.activePlayer, 0)
  }

  function test_bounce() {
    var game = runningGame()
    game.spheres = [{ id: 1, regionId: 1, x: 15.7, y: 0.3, vx: 4, vy: -4, radius: 0.28 }]

    Engine.step(game, 0.05)
    near(game.spheres[0].x, 15.72)
    near(game.spheres[0].y, 0.28)
    verify(game.spheres[0].vx < 0 && game.spheres[0].vy > 0)
  }

  function test_clear_next_and_single_player() {
    var game = runningGame()
    game.spheres = [stillSphere(12, 5)]
    game.targetCoverage = 0.5

    verify(Engine.placeWall(game, 8, 5))
    growUntilResolved(game)
    compare(game.status, "level-clear")
    compare(game.lastBonus, Math.round(game.timeRemaining * 25 + game.lives * 250))
    compare(game.score, 5000 + game.lastBonus)
    compare(game.playerScores[0], game.score)
    compare(game.activePlayer, 0)

    var score = game.score
    var lives = game.lives
    verify(Engine.nextLevel(game))
    compare(game.wave, 2)
    compare(game.status, "running")
    compare(game.score, score)
    compare(game.lives, lives)
    compare(game.coverage, 0)
    compare(game.lastBonus, 0)
    compare(game.walls.length, 0)
    compare(game.regions.length, 1)
    compare(game.spheres.length, Engine.profile(2, "classic").spheres)
  }

  function test_clock() {
    var game = runningGame()
    game.spheres = [{ id: 1, regionId: 1, x: 2, y: 5, vx: 1, vy: 0, radius: 0.28 }]
    var clock = { remainder: 0 }

    // A one-second frame elapses the clock once but simulates at most 30 ticks.
    var remainder = Engine.advanceFrame(game, clock, 1)
    near(remainder, 1 / 120)
    compare(clock.remainder, remainder)
    near(game.timeRemaining, 104)
    near(game.spheres[0].x, 2 + 30 / 120)
  }
}
