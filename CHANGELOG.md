# Changelog

All notable changes to this project will be documented here. Format: [Keep a Changelog](https://keepachangelog.com/en/1.1.0/); versions follow [Semantic Versioning](https://semver.org/).

## [1.0.1] - 2026-09-27

### Fixed

- Optional launcher installation refuses collisions and symlinked paths; removal deletes only verified owned files.
- Added isolated XDG-root regression tests for launcher install, refusal, and removal.

Legacy launcher files without ownership sidecars require manual migration; the installer will not overwrite or remove them automatically.

## [1.0.0] - 2026-09-27

### Added

- Native fullscreen Omarchy overlay with single-player play, three difficulty profiles, keyboard/pointer input, pause, and a layout that adapts to ultrawide screens.
- A blurred, grainy painting whose claimed regions fade into focus over about 2.6 seconds (instant with reduced motion).
- Vertical and horizontal cuts with an oriented cursor, a cut toggle button, mouse-wheel and right-click rotation.
- Lacquered spheres with elastic sphere-to-sphere collisions and speed-scaled impact sounds.
- HUD with time and coverage gauges and life dots; toasts for captures, broken walls, and refused placements.
- Ten public-domain paintings, ten CC0 recordings, and original effects; local preferences and high scores.
- Offline validation, media notices, and release preview tooling.
- Opt-in `scripts/install-launcher.sh` that lists the game in the Omarchy app launcher with its own icon.
- Marketplace-ready root manifest, README, license, media notices, preview, and installation/removal instructions.

The earlier `0.1.0` version was an unreleased draft, not a published release.
