# Jezz Atelier Omarchy Plugin

## Objective

Build a publication-ready, self-contained Omarchy Shell plugin that adapts the Jezz Atelier kinetic gallery game to a native QML fullscreen overlay.

## Problem

The reference experience is a browser-based Three.js JezzBall-style game. Omarchy plugins run inside a long-lived Quickshell process, so the browser implementation cannot be packaged directly without adding a browser or helper runtime. The plugin needs a native, resource-conscious implementation that preserves the game loop and atelier identity without destabilizing the shell.

## Why

A native overlay gives Omarchy users a coherent desktop experience, supports keyboard and pointer input, follows the current plugin lifecycle, and can be installed and reviewed as a normal public Git repository.

## Confirmed product decisions

- Scope: self-contained first release.
- Include: local one-player mode, local two-player hot-seat co-op, three difficulties, ten-artwork gallery, ten-track audio collection, local high scores, local preferences, pause/resume, responsive fullscreen overlay, keyboard and pointer controls.
- Exclude from v1: WebRTC peer-to-peer multiplayer and encrypted save-file import/export. These require a helper/runtime surface that is disproportionate for a first marketplace release.
- Plugin kind: `overlay`.
- Plugin ID: `io.github.julianbruno.jezz-atelier`.
- Author identity: Julian Bruno / GitHub `julianbruno`.
- License target: MIT for original code, with separate third-party/public-domain attribution for media.
- Conversation language: Spanish. Repository-facing artifacts and UI copy: English.

## Research evidence

### Reference game

- Live reference: <https://jezz-atelier.ks2p92rqmk.chatgpt.site/>
- Verified from the deployed HTML, CSS, JavaScript bundle, and desktop/mobile Chromium captures.
- The original uses a 16×10 field, expanding horizontal/vertical walls, moving spheres, claimed empty regions, timed waves, score by newly claimed area, time/life completion bonuses, and alternating players after each resolved wall.
- Difficulty profiles:
  - Relaxed: five lives, slower spheres, 65% initial goal, 150-second initial timer.
  - Classic: three lives, standard speed, 75% initial goal, 105-second initial timer.
  - Expert: three lives, faster/denser waves, 78% initial goal, 100-second initial timer.
- The reference includes ten public-domain paintings and ten CC0 Bach recordings, both cycling by wave.
- The visual language uses near-black green surfaces, ivory text, gold actions/borders, cyan focus rings, serif display type, compact uppercase metadata, and reduced-motion/high-contrast accommodations.

### Omarchy plugin contract

- Official manual: <https://omarchy.org/manual/shell-plugins/>
- Official development guide: <https://plugins.omarchy.org/develop.html>
- Official publication guide: <https://plugins.omarchy.org/publish.html>
- Installed Omarchy package: `4.0.4-1`; the package version file still reports `4.0.0.alpha`, so compatibility evidence must name the package version used for testing.
- Current manifest schema: `schemaVersion: 1`.
- Third-party IDs cannot use `omarchy.*`.
- Plugins are unsandboxed and run with the user’s permissions in the shared shell process.
- Marketplace-ready repositories require a root `manifest.json`, README, license, safe install/removal instructions, and optionally a preview image.
- Validation commands:
  - `omarchy plugin validate .`
  - `qmllint -I "$OMARCHY_PATH/shell" <QML files>`
- Installation command shape:
  - `omarchy plugin add https://github.com/julianbruno/omarchy-jezz-atelier.git --enable`

## Scope and constraints

- Keep runtime code self-contained: QML, QML JavaScript, JSON, and bundled media only.
- Do not spawn a second Quickshell process.
- Do not require sudo, network access, external executables, accounts, or install hooks.
- Do not mutate `~/.config/omarchy/` during repository development.
- Do not edit `/usr/share/omarchy/`.
- Use the official overlay lifecycle: `open(payloadJson)`, `close()`, `toggle()`, and host-aware dismiss through `shell.hide(pluginId)`.
- Cap animation work when the overlay is closed or paused.
- Keep input usable with keyboard and pointer; expose visible instructions and focus state.
- Preserve public-domain/CC0 credits and source links for every bundled media asset.
- No symlinks in the plugin tree.

## Testing mode

- Mode: strict TDD.
- Source: explicit user decision in this session.
- Primary runner: `QT_QPA_PLATFORM=offscreen /usr/lib/qt6/bin/qmltestrunner -input tests -import . -import "$OMARCHY_PATH/shell"`.
- Static validation: `/usr/lib/qt6/bin/qmllint -I "$OMARCHY_PATH/shell"` over every QML entry point and component.
- Toolchain note: `/usr/bin/qmltestrunner` and `/usr/bin/qmllint` belong to `qt5-declarative` and must not be used; the Qt 5 runner exits 1 silently on Qt 6 unversioned imports. Qt 6 tools come from `qt6-declarative 6.11.2-1`.
- Known lint baseline: `PanelWindow ... [uncreatable-type]` is also reported for the official `reminders/ReminderFlow.qml` and is not a plugin defect.
- Engine behavior source: `odd/specs/engine-rules.md` (reference-derived rules, original prose).
- Manifest validation: `omarchy plugin validate .`.
- TDD evidence must record observed RED, GREEN, and REFACTOR outcomes for engine and persistence behavior.

## Delivery plan

- Branch: `feat/jezz-atelier-plugin`.
- Delivery strategy: `ask-on-risk`.
- Chain strategy: `feature-branch-chain` (explicit user selection).
- Tracker branch: `feat/jezz-atelier-plugin`.
- Planned child sequence:
  1. `feat/jezz-atelier-engine` → tracker branch.
  2. `feat/jezz-atelier-overlay` → engine branch.
  3. `feat/jezz-atelier-collection` → overlay branch.
  4. `feat/jezz-atelier-polish` → collection branch (added after user play-testing).
  5. `feat/jezz-atelier-release` → polish branch.
- Forecast: approximately 1,800–2,600 authored changed lines, excluding bundled media and generated preview files.
- Each child keeps one coherent work unit with its tests and documentation. If an honest slice still exceeds the review heuristic, record the exact count and recommend `size:exception` rather than compressing code.
- No push, remote repository creation, pull request creation, marketplace submission, or merge is authorized yet.

## Tasks

- [x] **JZA-BLOCKER — Rebind Pi to the initialized Git repository** *(resolved: Pi reloaded from the repository)*
  - Restart or reload Pi from `/home/julian/miscodigos/jezzatelier` so the parent session owns the new clone and can register delegated worktrees.
  - Reconcile the task file and Engram mirror, confirm `feat/jezz-atelier-engine`, then relaunch the bounded JZA-001 writer.
  - Evidence: the original writer launch, explicit `workspace_root`, explicit `repository_root`, and `session_worktree_register` all failed before child execution because this session started before `git init`.

- [x] **JZA-001 — Establish the plugin contract and tested game engine**
  - Route: delegated writer.
  - Trigger: multi-file implementation and TDD preparation.
  - Create the schema-1 manifest and repository structure.
  - Write failing Qt Quick tests for difficulty profiles, deterministic reset, wall placement, collision/life loss, region claiming, scoring, timer loss, level progression, and hot-seat turn rotation.
  - Implement the reusable QML JavaScript engine until tests pass, then refactor.
  - Checks: focused `qmltestrunner`, manifest validation, static lint for created QML.
  - RED: Qt 6 runner `Script .../engine/Engine.js unavailable`, `Totals: 0 passed, 1 failed` before the engine existed.
  - GREEN: `Totals: 11 passed, 0 failed, 0 skipped, 0 blacklisted`.
  - REFACTOR: parent review expanded the compacted writer output into readable named helpers (`resetField`, `openRegionAt`, `completeWall`, `breakWall`, `growWall`, `moveSpheres`, `award`), normalized difficulty ids to `relaxed`/`classic`/`expert` for stable persistence keys, made `nextLevel` return a boolean, and strengthened the clock test to measure the 30-tick cap by sphere displacement. Tests stayed green: `Totals: 11 passed, 0 failed`.
  - Checks: Qt 6 `qmllint` reports only the known `PanelWindow` baseline warning; `omarchy plugin validate .` exits 0; a Node smoke run of 600 frames at 60 fps stays `running` with the clock at 95 s.
  - Authored lines: engine 393, tests 213, manifest 10, overlay placeholder 43, engine spec in `odd/specs/engine-rules.md`.
  - Commit evidence: pending.

- [x] **JZA-002 — Build the native fullscreen gameplay overlay**
  - Route: delegated writer.
  - Trigger: multi-file QML UI and input implementation.
  - Implement official overlay lifecycle and host-aware close behavior.
  - Render the board, artwork, balls, completed walls, growing-wall preview, claimed regions, HUD, menus, pause, wave-clear, and game-over states.
  - Support keyboard and pointer controls, local 1P/2P, responsive layouts, reduced motion, and visible focus.
  - Add or extend behavior tests before implementation changes.
  - Checks: focused `qmltestrunner`, `qmllint`, headless/safe overlay smoke test where available.
  - RED: Qt 6 runner before implementation: missing `components`, `engine/Input.js`, and `engine/Layout.js`; `Totals: 11 passed, 4 failed, 0 skipped, 0 blacklisted, 30ms`.
  - GREEN: Qt 6 runner after implementation: `Totals: 26 passed, 0 failed, 0 skipped, 0 blacklisted, 47ms`.
  - REFACTOR: renamed the controller's `state` property (collided with QQuickItem), bound repeater delegates, removed unused/unsupported imports; an added full GameView smoke caught the reserved `escape` method name (`23 passed, 1 failed`), corrected it, and final tests stayed green: `Totals: 27 passed, 0 failed, 0 skipped, 0 blacklisted, 48ms`.
  - Validation: Qt 6 lint exit 0, only `Warning: JezzAtelier.qml:28:3: Type PanelWindow is not creatable. [uncreatable-type]`; `omarchy plugin validate .` exit 0. Board and HUD instantiated offscreen; PanelWindow/live shell not exercised.
  - Parent review RED: new tests for keyboard-only menu/pause flow, preview refresh on simulation updates, frame-hitch clock protection, and segment geometry failed first: `Totals: 27 passed, 4 failed`.
  - Parent review GREEN/REFACTOR: preview now re-evaluates on every published revision; `P` resumes from pause; Enter/Space trigger the dialog's primary action; frame time is capped at 0.25 s so hitches cannot drain the clock; dialog copy moved from nested ternaries into named functions; triplicated wall geometry replaced by `WallSegment` + `Layout.segmentRect` with thickness scaled to board size. `Totals: 31 passed, 0 failed, 0 skipped, 0 blacklisted`.
  - Visual evidence: offscreen `GameView` renders at 1280×720 and 900×1200 (menu, running 2P, paused dialog, claimed region with growing wall and invalid preview) matched expectations. PanelWindow, Wayland focus, and live-shell lifecycle remain unverified until JZA-004 smoke checks.
  - Authored lines: 870 (overlay entry, components, input/layout helpers, and their tests).
  - Commit evidence: committed on `feat/jezz-atelier-overlay`.

- [x] **JZA-003 — Add collection media, audio, preferences, and scores**
  - **JZA-003a — Bundled media collection** (implemented; JZA-003 remains open for integration, preferences, and scores).
    - RED: Qt 6 runner before `Collection.js` existed: `Script .../engine/Collection.js unavailable`; `Totals: 31 passed, 1 failed, 0 skipped, 0 blacklisted`.
    - GREEN: 10 artwork images decoded by Qt Quick and catalog behavior passed alongside existing tests: `Totals: 36 passed, 0 failed, 0 skipped, 0 blacklisted`.
    - REFACTOR: replaced dynamic Image creation with a typed QML Image to remove lint warnings; media synthesis uses ffmpeg sine oscillators with deterministic envelope and peak normalization. Final checks recorded below.
    - Commons API `LicenseShortName` (exact): `Public domain` for rubens-rainbow, lorrain-harbour, poelenburch-gods, rembrandt-night-watch, caravaggio-emmaus, vermeer-art-of-painting, vermeer-delft, rubens-garden-love, velazquez-meninas, rembrandt-storm; `CC0` for bach-01, bach-02, bach-03, bach-04, bach-06, bach-07, bach-18, bach-26, bach-36, bach-41. Project-original build, capture, life-lost, level-clear, game-over: `CC0 1.0 (project original)` (not Commons API assets). No substitutes.
    - Sizes: artwork 3,127,117 bytes; music 12,000,815 bytes; sfx 156,778 bytes; total 15,284,710 bytes. `scripts/check-media.sh`: `Media inventory OK: 25 assets`; all listed files checked for existence, byte size, SHA-256, and Collection.js reference, and no unlisted files.
    - Build observations: Commons temporarily returned HTTP 429; builder honored Retry-After and completed. Cached originals stay outside the repository. Bundle runtime is offline.
    - Parent review RED/GREEN: catalog entries gained `sourceUrl` (test required a Commons file page for every entry: `4 passed, 1 failed` → `5 passed`). `engine/Collection.js` is now the single catalog source; `scripts/build-media.sh` reads it through Node instead of duplicating it on one 5,000-character line, rejects any catalog/Commons license mismatch, and strips tracking query strings from `originalUrl`. Re-running the builder reproduced all 25 assets byte-for-byte (identical aggregate SHA-256). Full suite: `Totals: 36 passed, 0 failed`.
    - Commit evidence: committed on `feat/jezz-atelier-collection` as the media work unit.
  - **JZA-003b — Gallery, audio, preferences, and high scores**
    - RED: Qt 6 runner with new pure-logic tests reported missing `engine/Storage.js` and `engine/Events.js`: `Totals: 36 passed, 2 failed`; integration tests before UI changes reported missing board artwork/preferences: `Totals: 44 passed, 2 failed`.
    - GREEN: pure logic and view integration pass with existing tests: `Totals: 46 passed, 0 failed, 0 skipped, 0 blacklisted, 264ms`.
    - REFACTOR: removed a QQuickItem signal-name collision, qualified setting-row bindings, and aligned claimed image fragments with the full board. Tests remained green (46 passed).
    - Parent review RED: board veil and human-readable menu labels were asserted first (`MenuPanel is not a type`; veil at default brightness was 0.15).
    - Parent review GREEN/REFACTOR: extracted `components/MenuPanel.qml` from `GameView.qml` (486 → ~330 lines, fixed mis-indented Play section); tabs show the selected section; settings read `Brightness 82%`, `Music 60%`, `Effects 80%`; gallery mode reads `MODE · TOUR BY WAVE`/`MODE · FIXED PAINTING` with a position counter, and browse buttons sit above the preview so they are never clipped; the open field veil now scales 0.30–0.75 with brightness (0.45 at the default) so claimed regions visibly uncover the painting, with the gold board frame restored; the board shows a "Now showing" caption. `AudioDirector` preloads one `SoundEffect` per sound through an `Instantiator` (no hot source swapping or cut-offs) and receives events through a typed `Connections` target; `Storage.js` was reformatted into named validators without the Node `require` workaround. Final: `Totals: 49 passed, 0 failed, 0 skipped, 0 blacklisted`; Qt 6 lint reports only the known `PanelWindow` baseline warning.
    - Live Quickshell evidence (ephemeral `quickshell -p` harness, temporary `XDG_STATE_HOME`): missing state file → defaults and parent directory created on save; written preferences and high score read back on the next run; corrupt JSON with out-of-range values → defaults without errors. `AudioDirector` loaded and played a sound effect and music under Qt 6 QtMultimedia.
    - Checks: `omarchy plugin validate .` exit 0; `scripts/check-media.sh` → `Media inventory OK: 25 assets`.
    - Authored lines for this unit: about 600 across new files plus 262 insertions / 63 deletions in modified files.
    - Remaining live-shell checks (JZA-004): Wayland keyboard focus inside the layer-shell window, audible output through the Omarchy session, and install/enable/summon/hide/remove lifecycle.
  - Route: delegated writer.
  - Trigger: multi-file feature and asset integration.
  - Bundle ten appropriately sized public-domain artwork images and ten CC0 music tracks, with machine-readable attribution metadata.
  - Implement gallery browsing, per-wave/fixed artwork selection, brightness, music/SFX volume, local preferences, and local high scores.
  - Ensure audio and animation stop when the overlay closes or pauses.
  - Add persistence/metadata tests first and record RED/GREEN/REFACTOR evidence.
  - Checks: focused tests, media inventory checks, license/source audit, lint, manifest validation.
  - Commit evidence: pending.

- [x] **JZA-005 — Gameplay and UI polish from user play-testing**
  - Trigger: user feedback after the first live run — spheres lacked texture, spheres passed through each other, horizontal cutting was not discoverable (it existed behind `R`/right-click with no visible affordance), and the UI/UX needed work.
  - Engine (strict TDD; RED `12 passed, 4 failed` → GREEN): equal-mass elastic sphere-sphere collisions with separation and re-clamping, documented in `odd/specs/engine-rules.md` as a deliberate divergence from the reference. Node stress run, 9 Expert spheres × 10 simulated minutes × 4 seeds: energy drift 0.000000 %, no escapes, no NaN, worst residual overlap 0.0044 units (triple contacts).
  - Presentation (strict TDD for logic; RED `3 passed, 5 failed` for `Events.feedback/placementRejection/newlyClaimed`, view RED `10 passed, 4 failed`): lacquered spheres (`Sphere.qml`, reference nine-color palette, radial shading, clear-coat highlight, contact shadow); oriented `WallCursor` with arrowheads; visible `↕ VERTICAL CUT / ↔ HORIZONTAL CUT` toggle, wheel rotation (once per 120-unit notch), right-click and `R`; toasts for captures, broken walls, turn changes, and refused placements with the reason; gold flash on newly claimed regions and red board flash on life loss (both off with reduced motion); HUD with stat blocks, life dots, time and coverage gauges with goal marker, and highlighted active player; action bar for pointer-only play; scrim behind in-game dialogs; menu over the current painting with the title in the dialog header, primary START, segmented 1P/2P choice, and a three-line how-to that names rotation; ultrawide side-panel layout (aspect > 1.9) so the board uses full height on 2560×1080.
  - Performance fix found in review: board Repeaters were bound to snapshot arrays that are replaced every frame, recreating every sphere and region delegate at 60 fps. They now use counts, so delegates persist and only bindings update.
  - Focus: the overlay re-requests keyboard focus when the layer-shell window becomes visible.
  - Checks: `Totals: 62 passed, 0 failed`; Qt 6 lint only the `PanelWindow` baseline; offscreen captures at 2560×1080, 1920×1200, and 1280×800 reviewed.

- [ ] **JZA-004 — Finish publication packaging and release evidence**
  - Route: delegated writer.
  - Trigger: multi-file documentation, scripts, and release packaging.
  - Add README, install/update/remove instructions, privacy/security notes, controls, compatibility statement, changelog, contribution guide, license, third-party notices, release checklist, and marketplace submission template.
  - Add reproducible validation scripts and a safe demo/preview workflow.
  - Produce an optimized marketplace preview and verify a clean local install/remove cycle without touching packaged Omarchy sources.
  - Checks: full tests, all QML lint, manifest validation, repository hygiene, asset/license audit, install/enable/summon/hide/disable/remove smoke checks in an isolated temporary user configuration.
  - Commit evidence: pending.

## Acceptance criteria

- `omarchy plugin validate .` succeeds.
- Every QML/JS test passes through the recorded runner.
- `qmllint` reports no errors for shipped QML.
- The plugin can be installed from the repository root, enabled, summoned, hidden, disabled, updated, and removed safely.
- The overlay does not animate or play audio while closed.
- One-player and local two-player games can reach wave clear and game over.
- Keyboard-only and pointer-only play are both viable.
- All bundled media have explicit title, creator, source URL, and public-domain/CC0 status.
- README and release artifacts are sufficient for a public GitHub repository and Omarchy marketplace submission.
- No external executable, elevated privilege, account, tracking, or network runtime dependency is introduced.

## Progress

- Deep reference-site and Omarchy-contract research completed.
- Product scope selected: self-contained v1.
- Git initialization and Conventional Commit authorization granted.
- Strict TDD selected.
- Local repository initialized on `feat/jezz-atelier-plugin`.
- Feature Branch Chain selected; tracker and four child slices defined.
- Planning baseline committed as `a995e1c3c7d8070058868c2e44388d7bdc4b58e7`.
- Engine child branch `feat/jezz-atelier-engine` created.
- First JZA-001 writer draft was reviewed and discarded: it used a cell grid instead of the reference region geometry, double-counted the anchor cell on collision, invented scoring/progression formulas, and its checks ran Qt 5 tools. Manifest and lifecycle placeholder were kept; engine and tests restart from RED.
- Reference engine rules extracted from the deployed bundle into `odd/specs/engine-rules.md`.
- JZA-001 engine and tests written from RED to GREEN, then refactored for readability after parent review; committed on `feat/jezz-atelier-engine`.

## Verification evidence

- `omarchy version`: `4.0.4-1`.
- `pacman -Q omarchy`: `omarchy 4.0.4-1`.
- `qmltestrunner`, `qmllint`, and Chromium are available locally.
- Reference desktop and mobile pages were rendered successfully in headless Chromium.
- JZA-001 Qt 6 tests: `Totals: 11 passed, 0 failed, 0 skipped, 0 blacklisted, 4ms`.
- Qt 6 lint (`JezzAtelier.qml tests/tst_engine.qml`): only the known `PanelWindow` uncreatable-type warning; exit 0.
- `omarchy plugin validate .`: no output; exit 0.

## Next step

Create `feat/jezz-atelier-release` from the collection branch and run JZA-004: README, license, third-party notices, changelog, contribution and security notes, validation scripts, marketplace preview, and an isolated install/enable/summon/hide/disable/remove smoke check.
