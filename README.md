# Jezz Atelier

![Jezz Atelier game preview](preview.png)

Jezz Atelier is a native, offline JezzBall-inspired kinetic gallery for the Omarchy desktop: split a moving field to reveal public-domain paintings, accompanied by a collection of CC0 music.

## Features

- One-player or local two-player hot-seat co-op; Relaxed, Classic, and Expert modes.
- Vertical and horizontal cuts, with an on-board cursor that shows the current orientation.
- Lacquered spheres that bounce off the walls and off each other, with impact sounds.
- Ten paintings, ten music tracks, original sound effects, gallery browsing, brightness and volume settings.
- Local high scores and preferences; keyboard-only or pointer-only play; pause and reduced-motion option.
- Layout that adapts to ultrawide screens by moving the HUD to a side panel.

## Requirements and installation

Omarchy with shell plugins (tested on package `omarchy 4.0.4-1`) and Qt 6.11. QtMultimedia is optional: the game runs silently without it. Review the source before enabling: plugins run **unsandboxed** in the shared shell process with your user permissions.

```sh
omarchy plugin add https://github.com/julianbruno/omarchy-jezz-atelier.git --enable
```

Summon the overlay with:

```sh
omarchy-shell shell summon io.github.julianbruno.jezz-atelier '{}'
```

**Optional:** add a shortcut to `~/.config/hypr/bindings.conf` (choose an unused key):

```ini
bindd = SUPER, J, Jezz Atelier, exec, omarchy-shell shell toggle io.github.julianbruno.jezz-atelier '{}'
```

The shell IPC contract accepts `summon <id> <payloadJson>`, `toggle <id> <payloadJson>`, and `hide <id>`; the wrapper also supplies `{}` if the third summon/toggle argument is omitted. Escape pauses during play; from a paused dialog it closes the overlay.

## Controls

| Action | Pointer | Keyboard |
| --- | --- | --- |
| Aim | Move over board | Arrow keys; Shift + arrows for faster movement |
| Build wall / confirm dialog | Left click / button | Space or Enter |
| Switch vertical ↕ / horizontal ↔ cut | Right click, mouse wheel, or the cut button | R |
| Pause / resume | Pause / Resume button | P |
| Open the menu (pauses the game) | Menu button | — |
| Pause, or close from a dialog | — | Escape |

## How to play

Place a horizontal or vertical wall inside open space while avoiding the moving spheres, which bounce off the walls and off each other. Both ends grow outward; if a sphere hits the unfinished wall, you lose a life. When the wall completes, any resulting region without a sphere is claimed, revealing the painting and earning points. Reach the coverage target before time or lives run out to advance to the next wave; remaining time and lives earn a bonus. In two-player mode, turns alternate after each wall resolves; progress and lives are shared.

## Update, disable, remove

```sh
omarchy plugin update io.github.julianbruno.jezz-atelier
omarchy plugin disable io.github.julianbruno.jezz-atelier
omarchy plugin remove io.github.julianbruno.jezz-atelier
```

After an update, run `omarchy-restart-shell`: the running shell keeps the previously loaded game code until it restarts.

Removal disables the plugin and removes its git checkout; it does **not** clear your saved scores/settings. Update previews the diff and requires a clean fast-forward checkout. Re-enable with `omarchy plugin enable io.github.julianbruno.jezz-atelier`.

## Data, privacy, and security

Preferences and local high scores are saved at `${XDG_STATE_HOME:-$HOME/.local/state}/jezz-atelier/state.json`. To reset, first disable/close the plugin, then delete **only that file** yourself; the next launch uses defaults. The game makes no network requests at runtime, runs no external executables, and uses no accounts or telemetry. It reads bundled assets and its own state file; as an unsandboxed plugin it nevertheless has your user's permissions in the shared shell process. See [SECURITY.md](SECURITY.md).

## Compatibility and development

Designed for the Omarchy overlay plugin contract; tested against Omarchy package `4.0.4-1` and Qt 6.11. Other shell versions and live installation/focus/audio behavior need independent testing. Run `scripts/validate.sh` for Qt 6 offscreen tests, lint, manifest, media and hygiene checks, and `scripts/smoke-lifecycle.sh` for an isolated install/update/remove run. To rebuild media (network, Node, Python, ImageMagick and ffmpeg required), use `scripts/build-media.sh`, then `scripts/generate-notices.sh` and validate. See [CONTRIBUTING.md](CONTRIBUTING.md).

## Credits and license

Original code and project-original sound effects: Julian Bruno, MIT ([LICENSE](LICENSE)). Paintings and recordings retain their own public-domain/CC0 status; full titles, creators, sources, and transformations are in [THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md).
