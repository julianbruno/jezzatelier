# Marketplace submission record

The [official publishing guide](https://plugins.omarchy.org/publish.html) directs maintainers to submit through its GitHub issue form **after** reviewing the public repository and completing the release checklist. It requires a public repository, valid root manifest, README and license, and safe installation and removal; a preview is optional. The [official submission form](https://raw.githubusercontent.com/omacom/omarchy-plugin-marketplace/main/.github/ISSUE_TEMPLATE/submit-plugin.yml) requests a repository link, one category, and 1–3 tags from its closed list. Listing validation is not a security audit.

- Repository: https://github.com/julianbruno/jezzatelier
- Category: Other (there is no Games category; Games is a tag)
- Tags: Games, Media, Quickshell
- Plugin name: Jezz Atelier
- Plugin ID: `io.github.julianbruno.jezz-atelier`
- Version: `1.0.0`
- Description: A single-player, fully offline JezzBall-inspired game for Omarchy: close off space around bouncing spheres to bring a blurred public-domain painting into focus.
- Preview: `preview.png` in repository root
- Install: `omarchy plugin add https://github.com/julianbruno/jezzatelier.git --enable`
- Optional app launcher entry: `~/.config/omarchy/plugins/io.github.julianbruno.jezz-atelier/scripts/install-launcher.sh`
- Remove: `omarchy plugin remove io.github.julianbruno.jezz-atelier`
- License: MIT for original code; separate public-domain/CC0 media notices in `THIRD_PARTY_NOTICES.md`.
- External dependencies: document any required external dependencies in the submission; verify the repository instructions before claiming none.
- Configuration: confirm installation does not overwrite existing user configuration without consent.
- Publication rights and form declarations: the user explicitly affirmed all five official form checkboxes, including ownership/preview permission, external dependencies, configuration safety, and acknowledgement that listing is not a security audit.

The public main branch and annotated `v1.0.0` tag were read back at release commit `d0db7689f080d93bec1c87d39db15ab9394105d4`. Exactly one issue was submitted: [marketplace issue #9069](https://github.com/omacom/omarchy-plugin-marketplace/issues/9069); its title and body matched on read-back. It was OPEN with no labels at first read-back. Routing workflow run `36368616116` subsequently completed successfully. The public validation comment confirms root README/LICENSE, manifest, Quattro compatibility, and preview at `d0db768`, and says “Ready for listing review.” Issue #9069 remains OPEN with labels `submission`, `validated`, and `security-review-required`. The automated security baseline flagged installer/setup path `scripts/install-launcher.sh` and the filename `odd/tasks/game-description-and-local-install.md`; a maintainer must manually review these before applying `approved-and-verified`. This flag does not necessarily require a code change. Validation and issue submission do **not** mean marketplace approval or listing. Live launcher search, focus, and audible playback are not confirmed. Remove the optional launcher entry with `install-launcher.sh --remove` before removing the plugin if installed.
