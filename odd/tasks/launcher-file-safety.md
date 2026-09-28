# Launcher file safety

## Objective
Fix the concrete `needs-fixes` finding on [marketplace issue #9069](https://github.com/omacom/omarchy-plugin-marketplace/issues/9069): the optional launcher script must not overwrite unrelated desktop/icon files, follow symlinks into other user files, or delete files it cannot identify as its own. Ship the fix as version 1.0.1, commit and fast-forward push the reviewed work, then update the local Omarchy plugin.

## Why and scope
The validated release `d0db768` writes two fixed XDG data paths without ownership checks, and `--remove` unlinks them blindly. Keep the launcher optional and its desktop entry/icon behavior; change only the install/remove safety boundary, isolated regression tests, test invocation, and user instructions. Preserve unrelated files, including generated `.codegraph/` data. Do not change the already published `v1.0.0` tag, marketplace issue, or labels. The user subsequently authorized a 1.0.1 version bump, commit, non-force push to public main, and local plugin update; this does not authorize a new tag, marketplace issue edit, or changing existing user launcher files.

## Constraints and acceptance
- Reject existing unowned targets, symlinked leaf/parent paths, and unsafe hard-linked files without clobbering external sentinels. No deletion of unrelated or modified files; refuse uncertain ownership instead.
- A first install into absent safe paths succeeds, an identical rerun is harmless, and an owned removal deletes only verified owned files. Fail safely on partial installation.
- The shell-only fix must not claim resistance to hostile concurrent directory swaps unless it actually provides descriptor-relative no-follow operations. Document the supported stable-user-directory boundary.
- Regression tests use an isolated temporary XDG data root, cover install, rerun, remove, conflict, symlink, hardlink, and modified-owned scenarios. Include tests in `scripts/validate.sh`; check shell syntax and the existing project suite.
- Verification evidence: focused test command and result, full suite, and runtime harness scenario/result; record unavailable checks honestly.

## Tasks
- [ ] LFS-1 Implement safe launcher ownership/refusal semantics, isolated regression tests, documentation, and 1.0.1 manifest/changelog as one reviewable patch work unit. Route: delegated writer for safety fix and version metadata. Check: focused shell regressions and `scripts/validate.sh`, then independent verification per risk assessment. Commit with a Conventional Commit message on `fix/launcher-file-safety`; record commit SHA when checks pass. Rollback boundary: launcher script, launcher tests, validate wiring, related launcher documentation, manifest and changelog only.
- [ ] LFS-2 Confirm remote main ancestry, fast-forward push the reviewed patch without force, read back public HEAD, update the installed plugin and restart/ping Omarchy shell. Do not run the optional launcher installer against existing user files without separate review. Leave issue #9069 and all marketplace labels unchanged.

## Progress
- Read-only scout mapped the two fixed paths, absent tests, and optional launcher documentation. TDD mode for this feature: not explicitly configured (historic strict TDD belonged to gameplay); ordinary functional checks with regression-first evidence. Focused runner: `bash tests/test-install-launcher.sh`; full runner: `bash scripts/validate.sh`. Forecast under ~400 authored diff lines; delivery strategy `ask-on-risk`. User has now authorized non-force push and local plugin update, but not a new tag or issue edit.
- On `fix/launcher-file-safety`, a delegated writer added ownership sidecars, exact expected-byte checks, no-clobber writes, safe refusal, temporary-XDG regressions, validate wiring, and user guidance. RED: initial unowned-file test failed; forged-sidecar and newline-path regressions also failed before correction. GREEN: both focused cases and complete launcher matrix pass. Independent verifier reran syntax, launcher regressions, full validation (77 Qt tests, 25 QML linted, 27 assets), and `git diff --check`; all passed. The parent separately reproduced both old exploits in disposable XDG paths and confirmed that the corrected code refuses both without touching outside/unrelated files. Isolated lifecycle smoke passed against old committed `d503a65`; it does not test uncommitted launcher code.
- Native risk assessment was unavailable because the worktree contains untracked files; the fallback required independent verification, which completed. Shell checks assume stable user-controlled directories and do not prevent hostile concurrent path swaps. Sidecars plus exact content are consistency evidence, not proof against same-user deliberate forgery. Real launcher search/audio were not verified.

## Next step
Bump version to 1.0.1, revalidate, commit the reviewed launcher work unit, push main by fast-forward and update the local plugin. Marketplace issue #9069 still refers to the old validated commit until a separately authorized revalidation; do not edit it as part of this task.
