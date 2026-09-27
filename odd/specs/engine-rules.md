# Jezz Atelier engine rules

Behavioral specification for the native engine, derived from reading the deployed reference bundle (`GameExperience-*.js`, 2026-09-27). This document describes behavior in original prose; the plugin implementation must be original code.

## Field and geometry

- The field is a continuous 16 × 10 rectangle in world units, origin at the top-left: `x ∈ [0, 16]`, `y ∈ [0, 10]`.
- The field is partitioned into axis-aligned rectangular **regions** `{id, minX, maxX, minY, maxY, claimed}`. A new wave starts with one unclaimed region covering the whole field.
- Region and wall ids come from monotonically increasing counters that restart at 1 on reset and on each new wave's region list.

## Spheres

- Each sphere: `{id, regionId, x, y, vx, vy, radius}` with `radius = 0.28`.
- Spawn: for each sphere, try up to 40 random positions with `x ∈ [0.88, 15.12]`, `y ∈ [0.88, 9.12]`, accepting the first whose distance to every earlier sphere is greater than `3 × radius` (after 40 tries keep the last candidate). Heading is a uniform angle in `[0, 2π)`. Speed is `uniform(2.2, 3.1) × globalSpeedScale × profile(wave).speedScale`, where `globalSpeedScale` defaults to 1.
- Movement: each step moves the sphere by `v × dt`, then clamps it inside its own region. Crossing `minX`/`maxX` sets `x` to the edge ± radius and forces `vx` to point inward (absolute value); same for `y`. Spheres never leave their region.
- Sphere collisions (**deliberate divergence from the reference**, which lets spheres pass through each other): after movement, every overlapping pair in the same region is pushed apart equally along the line between centers; if the pair is approaching, the two spheres exchange their velocity components along that line (equal-mass elastic collision, kinetic energy conserved). Both spheres are then re-clamped inside their region. Pairs are resolved once per tick in index order, which keeps the simulation deterministic.

## Difficulty profiles

`n = max(0, floor(wave) − 1)`.

| Profile | Spheres | Speed scale | Target coverage | Time limit (s) | Lives |
| --- | --- | --- | --- | --- | --- |
| `relaxed` | `min(6, 2 + floor(n/3))` | `0.75 + min(0.25, 0.02n)` | `0.65 + min(0.07, 0.01·floor(n/3))` | `max(120, 150 − 2n)` | 5 |
| `classic` | `min(9, 3 + n)` | `1 + min(0.30, 0.025n)` | `0.75 + min(0.03, 0.005·floor(n/3))` | `max(90, 105 − 2n)` | 3 |
| `expert` | `min(9, 4 + n)` | `1.15 + min(0.35, 0.03n)` | `0.78 + min(0.04, 0.005·floor(n/3))` | `max(80, 100 − 2n)` | 3 |

Difficulty ids are `relaxed`, `classic`, and `expert`; unknown ids fall back to `classic`. Lives are set only on reset, not per wave.

## Status machine

`ready → running ⇄ paused`; `running → level-clear → running` (next wave); `running → game-over`.

- `start()` only moves `ready → running`.
- `togglePause()` only swaps `running` and `paused`.
- `nextLevel()` only works from `level-clear`: wave + 1, recompute target and timer from the profile, coverage 0, bonus 0, clear walls, one full-field region, spawn the new wave's spheres, status `running`. Lives and scores carry over.
- `reset(seed, playerCount, difficulty)` restores wave 1 with a fresh seeded random stream, `ready` status, profile lives, orientation `vertical`, active player 0, zero scores.

## Wall placement

- Orientation is global state (`vertical` default) toggled by `toggleOrientation()`.
- `placeWall(x, y)` succeeds only while `running`, with no wall already growing, and when `(x, y)` is strictly inside an unclaimed region by more than `0.09` on every side and is not within `radius + 0.09` of any sphere in that region.
- A placed wall stores its region, orientation, anchor `(x, y)`, two ends starting at the anchor coordinate on its axis, and limits equal to the region's bounds on that axis.
- `previewWall(x, y)` (for the UI) reports the region-spanning extent and validity for a prospective wall without mutating state.

## Wall growth, breakage, and completion

- Each step, both ends move outward at `7.5` units/s and clamp at their limits.
- After moving, if any sphere in the wall's region touches it, the **whole** growing wall is destroyed: lives − 1, the active player advances, and at 0 lives the status becomes `game-over`. Touching means: for a vertical wall, `|ball.x − anchorX| ≤ radius + 0.09` and the ball's vertical extent overlaps `[negativeEnd, positiveEnd]`; horizontal is symmetric.
- When both ends reach their limits, the wall completes: its region is replaced in place by two regions split at the anchor coordinate. Spheres are reassigned to the side containing them; each side with no spheres is `claimed`. The completed wall segment is recorded, the growing wall cleared, coverage updated, and the active player advances.

## Coverage, score, and wave clear

- `coverage = claimed area / 160`.
- Each coverage update awards `max(0, round((newCoverage − oldCoverage) × 10000))` points to the total and to the active player (before the turn advances).
- When `coverage ≥ targetCoverage`, a bonus `round(timeRemaining × 25 + lives × 250)` is added to the total and the active player, stored as `lastBonus`, and status becomes `level-clear`.

## Time

- `step(dt, {advanceClock})` does nothing unless `running`; `dt` is capped to 0.05.
- The clock decreases by `dt` (never below 0); reaching 0 sets `game-over` before walls/spheres advance in that step.
- The host drives the simulation with a fixed-step accumulator: elapse the real frame time on the clock once (frame time capped to 30 s), then run fixed `1/120` s steps without advancing the clock, at most 30 per frame, carrying the remainder (capped at `1/120`).

## Players

- `playerCount` is 1 or 2 (local hot-seat co-op). Lives, coverage, and progress are shared; `playerScores[0..1]` track attribution.
- The active player advances after every resolved wall (completed or broken), only in two-player mode.

## Randomness and snapshots

- A seeded 32-bit generator lives in state; a zero seed uses a fixed non-zero default. The same seed, profile, and player count always produce identical state. No logic may use `Math.random`.
- `snapshot()` returns a deep, JSON-safe copy of all observable state including the generator state, suitable for rendering and for local persistence.
