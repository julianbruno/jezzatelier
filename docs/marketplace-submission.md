# Marketplace submission draft

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
- Publication rights: the user affirmed permission to publish the game and preview assets. Other first-person form declarations remain pending: the submitter must personally acknowledge the external-dependency and configuration requirements and that listing is not a security audit. Do not check these on the submitter's behalf.

The repository is public, but the newest local changes are not necessarily pushed. This is a draft, not a submission or a claim that live launcher, focus, or audio checks passed. Remove the optional launcher entry with `install-launcher.sh --remove` before removing the plugin if installed.
