# Release checklist

- [ ] Run `scripts/validate.sh`; audit generated `THIRD_PARTY_NOTICES.md` against `assets/media.json` and Commons source pages.
- [ ] Render `scripts/render-preview.sh`, inspect `preview.png` and verify legibility, size and framing.
- [ ] Run `scripts/smoke-lifecycle.sh` on the release commit: it drives the real `omarchy plugin` add/enable/disable/update/remove commands in a throwaway `HOME` with the shell IPC stubbed out.
- [ ] In a live Omarchy session (with the user's consent), summon and hide the overlay, check Wayland keyboard focus and audible music and effects, and confirm that `omarchy-restart-shell` loads an update.
- [ ] Set `CHANGELOG.md` version 0.1.0 date (replace `YYYY-MM-DD`), rerun validation and inspect the release diff.
- [ ] Create public GitHub repository `julianbruno/omarchy-jezz-atelier`; enable private vulnerability reporting; choose appropriate topics (`omarchy`, `omarchy-plugin`, `qml`, `game`, `jezzball`).
- [ ] Tag reviewed release commit `v0.1.0`; confirm manifest version matches the tag and changelog.
- [ ] Submit repository link, category and tags using the [official marketplace issue form](https://plugins.omarchy.org/publish.html); use [marketplace-submission.md](marketplace-submission.md). Wait for automated validation of the current commit and maintainer approval.

References: [publishing](https://plugins.omarchy.org/publish.html), [development](https://plugins.omarchy.org/develop.html), [shell plugins](https://omarchy.org/manual/shell-plugins/). Publishing is a separate human decision.
