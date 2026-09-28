# Contributing

## Set up and check

Use Omarchy with shell plugins and Qt 6 (tested with Qt 6.11). Run `scripts/validate.sh` from the checkout; it executes offscreen Qt tests, lints every QML file, validates the manifest if Omarchy is installed, and checks media and repository hygiene. The Qt 6 tools are `/usr/lib/qt6/bin/qmltestrunner` and `/usr/lib/qt6/bin/qmllint`; `/usr/bin/qmltestrunner` and `/usr/bin/qmllint` may be Qt 5 and must not be used for these tests.

`scripts/smoke-lifecycle.sh [revision]` runs the plugin install/enable/update/remove lifecycle against a committed revision in a throwaway `HOME`; it never contacts the running shell.

For behavior changes, write a failing test first (strict TDD), observe RED, implement the smallest change, observe GREEN, then refactor with tests green. Copy-only documentation updates do not need a behavior RED; check links, commands, and manifest structure instead. Use Conventional Commits and keep related tests and docs with the change.

## Media

Only public-domain or CC0 sources are accepted. Update `engine/Collection.js` and use `scripts/build-media.sh` to verify Commons licenses and rebuild the bundle; this developer-only operation uses network access, Node, Python, ImageMagick and ffmpeg. Run `scripts/generate-notices.sh` and `scripts/validate.sh` afterward. Never add media without title, creator, exact license, source page, and either a verified date or an explicit unknown date. Do not infer a recording date from Commons upload or file dates.

Do not edit packaged Omarchy files or run the overlay in a second Quickshell process. See [SECURITY.md](SECURITY.md) before proposing new runtime dependencies.
