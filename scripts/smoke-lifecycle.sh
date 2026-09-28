#!/usr/bin/env bash
# Runs the real `omarchy plugin` add/enable/update/disable/remove commands against a
# committed revision, inside a throwaway HOME. `omarchy-shell` is replaced by a stub that
# answers the shell IPC calls and logs them, so the running desktop shell is never
# contacted and ~/.config/omarchy is never touched.
#
# Usage: scripts/smoke-lifecycle.sh [revision]   (default: HEAD)
set -euo pipefail
cd "$(dirname "$0")/.."

revision=$(git rev-parse --verify "${1:-HEAD}^{commit}")
id=$(jq -r '.id' manifest.json)
omarchy_path="${OMARCHY_PATH:-/usr/share/omarchy}"
work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT

step() { printf '\n== %s ==\n' "$*"; }
fail() { echo "smoke-lifecycle: $*" >&2; exit 1; }

# Upstream: a bare repository whose HEAD is the revision under test.
git init --quiet --bare "$work/upstream.git"
git push --quiet "$work/upstream.git" "$revision:refs/heads/main"
git -C "$work/upstream.git" symbolic-ref HEAD refs/heads/main

mkdir -p "$work/home" "$work/bin"
cat >"$work/bin/omarchy-shell" <<'STUB'
#!/usr/bin/env bash
# Stub of the shell IPC: known plugins come from the catalog, enabled ids from a file.
set -euo pipefail
echo "$*" >>"$SMOKE_WORK/ipc.log"
enabled="$SMOKE_WORK/enabled"
touch "$enabled"
known() { omarchy-plugin-catalog | jq -e --arg id "$1" 'any(.[]; .id == $id)' >/dev/null; }
[[ ${1:-} == shell ]] || exit 1
case "${2:-}" in
  rescanPlugins) ;;
  listPlugins)
    omarchy-plugin-catalog | jq --rawfile enabled "$enabled" '
      ($enabled | split("\n")) as $on
      | map(.id as $id | {id, name, kinds, firstParty, enabled: ($on | index($id) != null)})' ;;
  enablePlugin)
    if known "$3"; then grep -qxF "$3" "$enabled" || echo "$3" >>"$enabled"; echo ok; else echo unknown; fi ;;
  setPluginEnabled)
    if ! known "$3"; then echo unknown; exit 0; fi
    if [[ $4 == true ]]; then grep -qxF "$3" "$enabled" || echo "$3" >>"$enabled"
    else grep -vxF "$3" "$enabled" >"$enabled.tmp" || true; mv "$enabled.tmp" "$enabled"; fi
    echo ok ;;
  summon | toggle | hide) echo ok ;;
  *) echo "unsupported stub call: $*" >&2; exit 1 ;;
esac
STUB
chmod +x "$work/bin/omarchy-shell"

export HOME="$work/home" SMOKE_WORK="$work" OMARCHY_PATH="$omarchy_path"
export PATH="$work/bin:$omarchy_path/bin:$PATH"
export GIT_CONFIG_GLOBAL=/dev/null
plugin_dir="$HOME/.config/omarchy/plugins/$id"
is_enabled() { omarchy-plugin-list --json | jq -e --arg id "$id" 'any(.[]; .id == $id and .enabled)' >/dev/null; }

step "add --enable ($revision)"
omarchy-plugin-add "file://$work/upstream.git" --enable --yes </dev/null
[[ $(git -C "$plugin_dir" rev-parse HEAD) == "$revision" ]] || fail "installed revision differs"
is_enabled || fail "plugin not enabled after add"
[[ -z $(find "$plugin_dir" -type l -not -path '*/.git/*') ]] || fail "symlinks in installed tree"

step "summon and hide (stubbed IPC)"
omarchy-shell shell summon "$id" '{}' >/dev/null
omarchy-shell shell hide "$id" >/dev/null

step "disable and re-enable"
omarchy-plugin-disable "$id"
! is_enabled || fail "plugin still enabled after disable"
omarchy-plugin-enable "$id"
is_enabled || fail "plugin not enabled after re-enable"

step "update (fast-forward to an upstream commit)"
git clone --quiet "$work/upstream.git" "$work/next"
git -C "$work/next" -c user.name=smoke -c user.email=smoke@localhost commit --quiet --allow-empty -m "smoke: next"
git -C "$work/next" push --quiet origin HEAD:main
omarchy-plugin-update "$id" --yes </dev/null
[[ $(git -C "$plugin_dir" rev-parse HEAD) == $(git -C "$work/upstream.git" rev-parse main) ]] || fail "update did not fast-forward"
omarchy-plugin-update "$id" --yes </dev/null | grep -q "up to date" || fail "second update not idempotent"

step "remove"
omarchy-plugin-remove "$id" --yes </dev/null
[[ ! -e $plugin_dir ]] || fail "plugin directory still present"
! omarchy-plugin-list --json | jq -e --arg id "$id" 'any(.[]; .id == $id)' >/dev/null || fail "plugin still listed"

step "stubbed shell IPC calls"
cat "$work/ipc.log"
printf '\nLifecycle smoke OK: %s at %s\n' "$id" "$revision"
