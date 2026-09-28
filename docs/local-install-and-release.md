# Install, update, and prepare a release

Use this guide to keep a local Omarchy installation current. The plugin is a shell overlay; the optional desktop entry makes it searchable as an app, but does not replace the plugin. Publishing to GitHub or the marketplace is a separate decision.

## Update this computer

Run these commands **after committing changes** in the source repository. The installed plugin is a separate Git checkout under `~/.config/omarchy/plugins/`; on this development machine its `origin` points to the local source repository. Check that with `git -C ~/.config/omarchy/plugins/io.github.julianbruno.jezz-atelier remote -v` before updating.

```sh
omarchy plugin update io.github.julianbruno.jezz-atelier
omarchy restart shell
omarchy plugin list
```

The update requires a clean installed checkout and a fast-forward from its configured `origin`. Restart the shell to discard previously loaded QML types. The bar and overlays briefly disappear during the restart. Look for `io.github.julianbruno.jezz-atelier` marked `enabled` in the list. To open it without a desktop entry:

```sh
omarchy-shell shell summon io.github.julianbruno.jezz-atelier '{}'
```

The saved scores and preferences at `${XDG_STATE_HOME:-$HOME/.local/state}/jezz-atelier/state.json` are not removed by updating the plugin.

## Add it to the app launcher

After installing the plugin, run the optional script from its **installed checkout**:

```sh
~/.config/omarchy/plugins/io.github.julianbruno.jezz-atelier/scripts/install-launcher.sh
```

It creates a desktop entry in `${XDG_DATA_HOME:-$HOME/.local/share}/applications/` and an icon in the `icons/hicolor/256x256/apps/` directory under the same data home. Open the Omarchy menu (by default `SUPER + SPACE`), go to **Apps**, and search for “Jezz Atelier”. The desktop entry launches the shell overlay; it does not create a separate window. Launcher search and audio should be checked in the live session, not inferred from the automated tests.

An identical rerun is harmless, but changed icon or desktop content is not overwritten. Run `--remove` first for a verified owned installation, then run the installer again to upgrade. This version records device/inode and content hashes in adjacent `.jezz-atelier-owner` sidecars and also requires the exact current desktop template or bundled icon bytes before removal. A sidecar forged for unrelated content does not authorize deletion. An older installation without sidecars cannot be verified: inspect and back up the desktop entry and icon, remove them manually only if you confirm they are yours, then install again. Conflicts, modified files, symlinks and hard links are refused; a failed partial install may require manual inspection of an unowned file before retrying. Newline and carriage return characters in the XDG data path are refused. These shell checks assume stable user-controlled XDG directories and do not guarantee safety against hostile concurrent directory swaps; a forged sidecar paired with exact plugin bytes cannot be distinguished from an owned file. To remove the entry **before** uninstalling the plugin:

```sh
~/.config/omarchy/plugins/io.github.julianbruno.jezz-atelier/scripts/install-launcher.sh --remove
omarchy plugin remove io.github.julianbruno.jezz-atelier
```

## Install on another Omarchy computer

The [public repository](https://github.com/julianbruno/jezzatelier) is available. Review its code and install the published revision with:

```sh
omarchy plugin add https://github.com/julianbruno/jezzatelier.git --enable
omarchy restart shell
```

To add the optional app launcher, run the installed script in the preceding section. The public branch may not include the newest local changes; check the remote revision before assuming a feature is available. Plugins run unsandboxed in the shared shell process with your user permissions. The desktop entry is not automatically installed by `omarchy plugin add` because the plugin contract has no install hook.

## Before publication

1. Run `scripts/validate.sh`, `scripts/smoke-lifecycle.sh`, and `scripts/render-preview.sh` in the source checkout. The lifecycle smoke uses a temporary `HOME` and stubs the shell IPC; it does **not** prove live launcher, focus, or audio behavior.
2. Check the rendered `preview.png`, game controls, audio, and launcher search on a real Omarchy desktop. Verify that the copyright, name, source attribution, and release date are appropriate.
3. Review [the release checklist](release-checklist.md) and [marketplace submission draft](marketplace-submission.md). Confirm the published revision and whether development history under `odd/` belongs in the public repository.
4. Only after explicit approval: push the reviewed branch and tag the release. Marketplace submission is a separate approval and action.

The repository already exists publicly; these local commands do not push, tag, or submit anything.
