# Release checklist

- [ ] Run `scripts/validate.sh`; audit generated `THIRD_PARTY_NOTICES.md` against `assets/media.json` and Commons source pages.
- [ ] Render `scripts/render-preview.sh`, inspect `preview.png` and verify legibility, size and framing.
- [x] Run `scripts/smoke-lifecycle.sh` on the release commit: isolated lifecycle passed at release HEAD `d0db7689f080d93bec1c87d39db15ab9394105d4`.
- [ ] In a live Omarchy session (with the user's consent), summon and hide the overlay, check Wayland keyboard focus and audible music and effects, and confirm that `omarchy restart shell` loads an update.
- [ ] Confirm the `CHANGELOG.md` release date matches the day the tag is pushed, rerun validation and inspect the release diff.
- [x] Confirm the existing public repository [julianbruno/jezzatelier](https://github.com/julianbruno/jezzatelier) contains the reviewed release commit: atomic push of main and annotated `v1.0.0` tag confirmed by remote read-back, both at `d0db768`.
- [ ] Enable private vulnerability reporting and choose appropriate topics (`omarchy`, `omarchy-plugin`, `qml`, `game`, `jezzball`).
- [x] Tag reviewed release commit `v1.0.0`; manifest version is `1.0.0` and matches the changelog. Remote tag read-back resolves to `d0db768`.
- [ ] Confirm the public repository has a valid root manifest, README, license, and safe install/removal instructions (preview optional). Check the [official submission form](https://raw.githubusercontent.com/omacom/omarchy-plugin-marketplace/main/.github/ISSUE_TEMPLATE/submit-plugin.yml) and [marketplace-submission.md](marketplace-submission.md): choose Other (Games is a tag, not a category), and select the three allowed tags Games, Media, Quickshell. Document external dependencies and verify installation never overwrites user configuration without consent.
- [x] Confirm publication rights for the game and preview assets (affirmed by the user).
- [x] Before issue submission, the submitter personally affirmed all five official form checkboxes, including external dependencies, configuration safety, and acknowledgement that listing is not a security audit.
- [x] Submit exactly one issue and read back its title and body: [#9069](https://github.com/omacom/omarchy-plugin-marketplace/issues/9069) remains OPEN.
- [x] Confirm routing validation: workflow run `36368616116` completed successfully. Public comment confirms root README/LICENSE, manifest, Quattro compatibility, and preview at `d0db768`; status is “Ready for listing review.” Labels: `submission`, `validated`, `security-review-required`.
- [ ] Await manual security review and maintainer decision before `approved-and-verified` or listing. Automated baseline flagged installer/setup path `scripts/install-launcher.sh` and filename `odd/tasks/game-description-and-local-install.md`; no code change is necessarily required. Validation and issue submission are not approval or listing.

Release HEAD validation: 77 Qt tests, QML lint on 25 files, 27 assets, and isolated lifecycle passed. Installed plugin updated to `d0db768`; `omarchy restart shell` ping `ok` and plugin enabled. Live launcher search and audible playback remain unverified.

References: [publishing](https://plugins.omarchy.org/publish.html), [development](https://plugins.omarchy.org/develop.html), [shell plugins](https://omarchy.org/manual/shell-plugins/). Publishing is a separate human decision.
