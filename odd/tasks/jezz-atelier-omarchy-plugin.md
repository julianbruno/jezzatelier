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
- Primary runner: `qmltestrunner -input tests -import . -import "$OMARCHY_PATH/shell"`.
- Static validation: `qmllint -I "$OMARCHY_PATH/shell"` over every QML entry point and component.
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
  4. `feat/jezz-atelier-release` → collection branch.
- Forecast: approximately 1,800–2,600 authored changed lines, excluding bundled media and generated preview files.
- Each child keeps one coherent work unit with its tests and documentation. If an honest slice still exceeds the review heuristic, record the exact count and recommend `size:exception` rather than compressing code.
- No push, remote repository creation, pull request creation, marketplace submission, or merge is authorized yet.

## Tasks

- [ ] **JZA-001 — Establish the plugin contract and tested game engine** *(in progress)*
  - Route: delegated writer.
  - Trigger: multi-file implementation and TDD preparation.
  - Create the schema-1 manifest and repository structure.
  - Write failing Qt Quick tests for difficulty profiles, deterministic reset, wall placement, collision/life loss, region claiming, scoring, timer loss, level progression, and hot-seat turn rotation.
  - Implement the reusable QML JavaScript engine until tests pass, then refactor.
  - Checks: focused `qmltestrunner`, manifest validation, static lint for created QML.
  - Commit evidence: pending.

- [ ] **JZA-002 — Build the native fullscreen gameplay overlay**
  - Route: delegated writer.
  - Trigger: multi-file QML UI and input implementation.
  - Implement official overlay lifecycle and host-aware close behavior.
  - Render the board, artwork, balls, completed walls, growing-wall preview, claimed regions, HUD, menus, pause, wave-clear, and game-over states.
  - Support keyboard and pointer controls, local 1P/2P, responsive layouts, reduced motion, and visible focus.
  - Add or extend behavior tests before implementation changes.
  - Checks: focused `qmltestrunner`, `qmllint`, headless/safe overlay smoke test where available.
  - Commit evidence: pending.

- [ ] **JZA-003 — Add collection media, audio, preferences, and scores**
  - Route: delegated writer.
  - Trigger: multi-file feature and asset integration.
  - Bundle ten appropriately sized public-domain artwork images and ten CC0 music tracks, with machine-readable attribution metadata.
  - Implement gallery browsing, per-wave/fixed artwork selection, brightness, music/SFX volume, local preferences, and local high scores.
  - Ensure audio and animation stop when the overlay closes or pauses.
  - Add persistence/metadata tests first and record RED/GREEN/REFACTOR evidence.
  - Checks: focused tests, media inventory checks, license/source audit, lint, manifest validation.
  - Commit evidence: pending.

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
- JZA-001 started.

## Verification evidence

- `omarchy version`: `4.0.4-1`.
- `pacman -Q omarchy`: `omarchy 4.0.4-1`.
- `qmltestrunner`, `qmllint`, and Chromium are available locally.
- Reference desktop and mobile pages were rendered successfully in headless Chromium.

## Next step

Commit the planning baseline on the tracker branch, create `feat/jezz-atelier-engine`, and execute JZA-001 with observed TDD evidence.
