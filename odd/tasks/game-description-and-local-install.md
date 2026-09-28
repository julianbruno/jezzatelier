# Game description and marketplace readiness

## Objective
Keep the installed Omarchy plugin current, align all public-facing guides and manifest copy with the single-player game, and prepare the actual public repository for the official marketplace submission without submitting it.

## Constraints
- No GitHub repository creation, push, release tag, or marketplace submission without explicit approval.
- Avoid injecting input into the user's desktop; launcher search and audible playback remain user-confirmed checks.
- Keep repository-facing docs in English, following existing conventions.

## Tasks
- [x] DOC-1 Update the installed plugin and restart Omarchy shell. Evidence: installed checkout at `966dd85`; `omarchy restart shell` returned successfully; shell ping `ok`; plugin list reports enabled.
- [x] DOC-2 Align README, manifest description, and user-facing docs with current single-player gameplay, official marketplace requirements, and the real public repository `julianbruno/jezzatelier` (confirmed by GitHub API on main at `966dd85`). Evidence: README overview/install, CHANGELOG, CONTRIBUTING, SECURITY, manifest description, marketplace draft and checklist updated; new local install/release guide. Read-only scout found no multiplayer claims in public docs; stale public clone URLs corrected. Route: delegated scout (4+ files) and delegated writer (multi-file changes).
- [x] DOC-3 Verify docs, manifest, bundled files, and install lifecycle; commit a reviewable work unit, then update this PC from that commit and restart the shell. Evidence: media commit `059548d` and release commit `d0db7689f080d93bec1c87d39db15ab9394105d4`; 77 Qt tests, QML lint on 25 files, 27 assets, and isolated lifecycle validated at release HEAD. Installed plugin updated to `d0db768`; `omarchy restart shell` ping `ok`, plugin enabled. Live launcher search and audible playback remain unverified.

## Progress
- Official `plugins.omarchy.org/publish.html` requires a public GitHub repository, root manifest, README/license, safe install/removal, optional preview, and issue-form submission; marketplace validates listings, not security. Direct inspection of the actual `submit-plugin.yml` found category `Games` invalid (use `Other`) and tags restricted to 1–3 predefined choices (use `Games`, `Media`, `Quickshell`); submission requires the human's ownership/preview-permission confirmation. Submission itself remains out of scope.
- Repo is public at `https://github.com/julianbruno/jezzatelier`; atomic push of main and annotated `v1.0.0` was confirmed by remote read-back, both resolving to `d0db768`. The older `omarchy-jezz-atelier` URLs in docs are invalid.
- `.codegraph/` is untracked tool-generated data; do not include it in the release.

## Next step
Documentation and release work is published and locally installed. Marketplace issue #9069 remains OPEN; routing workflow `36368616116` succeeded and public validation marked `d0db768` ready for listing review. Labels are `submission`, `validated`, and `security-review-required`. Automated security baseline flagged `scripts/install-launcher.sh` and the filename of this task document; manual maintainer review is required before `approved-and-verified` (not necessarily a code change). The plugin is not approved or listed; live launcher search and audible playback still require user verification.
