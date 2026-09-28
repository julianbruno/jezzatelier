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
- [ ] DOC-3 Verify docs, manifest, bundled files, and install lifecycle; commit a reviewable work unit, then update this PC from that commit and restart the shell. Check: validation suite, isolated lifecycle smoke, live installed revision and shell ping; record unavailable live launcher/audio checks. Route: delegated verifier (command verification).

## Progress
- Official `plugins.omarchy.org/publish.html` requires a public GitHub repository, root manifest, README/license, safe install/removal, optional preview, and issue-form submission; marketplace validates listings, not security. Submission itself remains out of scope.
- Repo is public at `https://github.com/julianbruno/jezzatelier` (default branch main at `966dd85`). The older `omarchy-jezz-atelier` URLs in docs are invalid. Git SSH remote auth currently fails in this environment; do not claim a push.
- `.codegraph/` is untracked tool-generated data; do not include it in the release.

## Next step
Delegate scoped documentation updates; verify, commit, and update the local plugin without submitting or pushing.
