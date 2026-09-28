# Release checklist

- [ ] Run `scripts/validate.sh`; audit generated `THIRD_PARTY_NOTICES.md` against `assets/media.json` and Commons source pages.
- [ ] Render `scripts/render-preview.sh`, inspect `preview.png` and verify legibility, size and framing.
- [ ] Run `scripts/smoke-lifecycle.sh` on the release commit: it drives the real `omarchy plugin` add/enable/disable/update/remove commands in a throwaway `HOME` with the shell IPC stubbed out.
- [ ] In a live Omarchy session (with the user's consent), summon and hide the overlay, check Wayland keyboard focus and audible music and effects, and confirm that `omarchy restart shell` loads an update.
- [ ] Confirm the `CHANGELOG.md` release date matches the day the tag is pushed, rerun validation and inspect the release diff.
- [ ] Confirm the existing public repository [julianbruno/jezzatelier](https://github.com/julianbruno/jezzatelier) contains the reviewed release commit; enable private vulnerability reporting; choose appropriate topics (`omarchy`, `omarchy-plugin`, `qml`, `game`, `jezzball`). Do not assume local changes are already pushed.
- [ ] Tag reviewed release commit `v1.0.0`; confirm manifest version matches the tag and changelog.
- [ ] Confirm the public repository has a valid root manifest, README, license, and safe install/removal instructions (preview optional). Check the [official submission form](https://raw.githubusercontent.com/omacom/omarchy-plugin-marketplace/main/.github/ISSUE_TEMPLATE/submit-plugin.yml) and [marketplace-submission.md](marketplace-submission.md): choose Other (Games is a tag, not a category), and select the three allowed tags Games, Media, Quickshell. Document external dependencies and verify installation never overwrites user configuration without consent.
- [x] Confirm publication rights for the game and preview assets (affirmed by the user).
- [ ] Before issue submission, the submitter must personally confirm all other first-person form declarations, including external dependencies, configuration safety, and acknowledgement that marketplace listing is not a security audit. Do not check these on the submitter's behalf; submission and maintainer approval remain separate steps.

References: [publishing](https://plugins.omarchy.org/publish.html), [development](https://plugins.omarchy.org/develop.html), [shell plugins](https://omarchy.org/manual/shell-plugins/). Publishing is a separate human decision.
