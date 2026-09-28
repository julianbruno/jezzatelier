# Marketplace v1.0.0 release

## Objective
Version Jezz Atelier at 1.0.0, publish the reviewed revision to the already-public GitHub repository, and submit the Omarchy marketplace issue using the exact official YAML form.

## Constraints
- User directly authorized committing and publishing via the issue form, and affirmed rights/permission to publish the game and preview assets.
- Form checkbox affirmations beyond the ownership question must not be inferred; stop for any missing first-person declaration.
- No destructive Git operations, no unreviewed ref overwrite, no duplicate issue, no blind retry after uncertain GitHub mutation.
- Do not add generated `.codegraph/` to the repository. Preserve user state in local Omarchy config.

## Tasks
- [x] REL-1 Bump manifest, changelog, submission draft, and checklist to 1.0.0; make publication copy accurate. Evidence: delegated writer updated four files, version/date parity check passed; full validation after media-credit changes passed 77 Qt tests, QML lint 25 files, manifest/media/hygiene checks. Pending worktree changes will be committed in REL-2.
- [ ] REL-2 Verify, commit, and tag the release on a reviewable branch; publish the exact reviewed revision on GitHub main without forcing. Verify remote read-back. Route: delegated verifier for commands; parent owns Git mutation.
- [ ] REL-3 Recheck the official issue form and policy, complete one open+closed duplicate search, gather any missing first-person affirmation, then submit exactly one compliant issue and read it back. Route: parent-owned external mutation. User affirmed ownership/permission; a later five-checkbox confirmation prompt was cancelled, so other first-person declarations remain unconfirmed. No issue mutation until affirmed.
- [ ] REL-4 Update the local installed plugin and restart Omarchy shell after the public revision is available. Verify revision, shell ping and enabled state. Route: delegated verification where possible; parent owns install.

## Evidence
- Public repo: https://github.com/julianbruno/jezzatelier (main at 966dd85 before release).
- Latest local candidate: feat/jezz-atelier-marketplace-docs at 3e850b0 with uncommitted form correction; manifest still 0.1.0; no tags.
- Official form: https://raw.githubusercontent.com/omacom/omarchy-plugin-marketplace/main/.github/ISSUE_TEMPLATE/submit-plugin.yml; category Other, tags Games/Media/Quickshell; checkbox ownership confirmed by user, other first-person declarations pending explicit confirmation.
- Secret audit: text in 21 reachable commits scanned with no credential hits; binary assets and unreachable objects not fully scanned.

## Next step
Commit the prepared 1.0.0 metadata and media-credit task evidence, verify the exact commit, fast-forward push main and tag v1.0.0 only after remote read-back. Issue form remains blocked on unconfirmed first-person checkboxes; user repeatedly requested submission but cancelled the exact confirmation prompt.
