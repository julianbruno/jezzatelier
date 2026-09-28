# Marketplace submission draft

The [official publishing guide](https://plugins.omarchy.org/publish.html) directs maintainers to submit through its GitHub issue form **after** reviewing the public repository and completing the release checklist. It requires a public repository, valid root manifest, README and license, and safe installation and removal; a preview is optional. The form requests a repository link, category, and tags. Automated listing validation does not certify plugin security.

- Repository: https://github.com/julianbruno/jezzatelier
- Category: Games
- Tags: `game`, `gallery`, `jezzball`, `overlay`
- Plugin name: Jezz Atelier
- Plugin ID: `io.github.julianbruno.jezz-atelier`
- Version: `0.1.0`
- Description: A single-player, fully offline JezzBall-inspired game for Omarchy: close off space around bouncing spheres to bring a blurred public-domain painting into focus.
- Preview: `preview.png` in repository root
- Install: `omarchy plugin add https://github.com/julianbruno/jezzatelier.git --enable`
- Optional app launcher entry: `~/.config/omarchy/plugins/io.github.julianbruno.jezz-atelier/scripts/install-launcher.sh`
- Remove: `omarchy plugin remove io.github.julianbruno.jezz-atelier`
- License: MIT for original code; separate public-domain/CC0 media notices in `THIRD_PARTY_NOTICES.md`.

The repository is public, but the newest local changes are not necessarily pushed. This is a draft, not a submission or a claim that live launcher, focus, or audio checks passed. Remove the optional launcher entry with `install-launcher.sh --remove` before removing the plugin if installed.
