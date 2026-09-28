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
- [x] REL-2 Verify, commit, and tag the release on a reviewable branch; publish the exact reviewed revision on GitHub main without forcing. Evidence: media commit `059548d`; release commit `d0db7689f080d93bec1c87d39db15ab9394105d4`; 77 Qt tests, QML lint on 25 files, 27 assets, and isolated lifecycle validated at release HEAD. Atomic push to public `julianbruno/jezzatelier` main and annotated `v1.0.0` tag confirmed by remote read-back; both resolve to `d0db768`.
- [x] REL-3 Recheck the official issue form and policy, complete one open+closed duplicate search, gather first-person affirmation, submit exactly one issue and read it back. Evidence: user explicitly affirmed all five official form checkboxes; exactly one issue created, with title and body matching at https://github.com/omacom/omarchy-plugin-marketplace/issues/9069. It was OPEN with no labels on first read-back. Subsequently, routing workflow run `36368616116` completed successfully; public validation marked the release ready for listing review, not approved or listed.
- [x] REL-4 Update the local installed plugin and restart Omarchy shell after the public revision is available. Evidence: installed plugin updated to `d0db768`; `omarchy restart shell` ping `ok` and plugin enabled. Live launcher search and audible playback were not verified.

## Evidence
- Public repo: https://github.com/julianbruno/jezzatelier (main at 966dd85 before release).
- Published main and annotated `v1.0.0` both resolve to release commit `d0db7689f080d93bec1c87d39db15ab9394105d4` by remote read-back.
- Official form: https://raw.githubusercontent.com/omacom/omarchy-plugin-marketplace/main/.github/ISSUE_TEMPLATE/submit-plugin.yml; category Other, tags Games/Media/Quickshell; all five checkboxes explicitly affirmed by the user. Issue #9069 remains OPEN with labels `submission`, `validated`, and `security-review-required`. Public validation confirmed root README/LICENSE, manifest, Quattro compatibility, and preview at `d0db768`, marking it “Ready for listing review.” Automated security baseline flagged the installer/setup path `scripts/install-launcher.sh` and the filename `odd/tasks/game-description-and-local-install.md`; manual maintainer review is required before `approved-and-verified`, with no code change necessarily required.
- Secret audit: text in 21 reachable commits scanned with no credential hits; binary assets and unreachable objects not fully scanned.

## Next step
Await manual security review and maintainer listing decision on issue #9069; validation succeeded, but approval and listing have not occurred. Private vulnerability reporting, repository topics, live launcher search, and audible playback remain unverified or pending; do not equate issue submission with marketplace listing.
