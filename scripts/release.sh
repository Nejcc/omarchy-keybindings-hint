#!/usr/bin/env bash
# Run after the prepared changes merge; publish the exact merged tree.
set -euo pipefail
root=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
cd "$root"
repo='Nejcc/omarchy-keybindings-hint'
gh auth status
if [[ -z "${GIT_SSH_COMMAND:-}" && -f "$HOME/.ssh/config" ]]; then
  export GIT_SSH_COMMAND="ssh -F '$HOME/.ssh/config' -o BatchMode=yes -o ConnectTimeout=10 -o StrictHostKeyChecking=yes"
fi
git fetch origin master
release_sha=$(git rev-parse origin/master)
[[ -z "$(git status --porcelain)" ]] || { printf 'Commit changes first.\n' >&2; exit 1; }
[[ "$(git rev-parse HEAD^{tree})" == "$(git rev-parse origin/master^{tree})" ]] || { printf 'Merge the release changes first.\n' >&2; exit 1; }
node --test tests/*.test.mjs
QT_QPA_PLATFORM=offscreen QT_QPA_PLATFORMTHEME=generic QT_QUICK_BACKEND=software /usr/lib/qt6/bin/qmltestrunner -input tests
version=$(python3 -c 'import json; print(json.load(open("manifest.json"))["version"])')
tag="v$version"
notes=$(mktemp)
trap 'rm -f "$notes"' EXIT
git show "$release_sha:CHANGELOG.md" > "$notes"
if git rev-parse --verify "refs/tags/$tag" >/dev/null 2>&1; then
  [[ "$(git rev-parse "$tag^{commit}")" == "$release_sha" ]] || { printf 'Tag already points elsewhere.\n' >&2; exit 1; }
else
  git -c user.name=nejcc -c user.email=nejc.cotic@gmail.com tag -a "$tag" "$release_sha" -m "Release $version"
fi
git push origin "refs/tags/$tag"
if ! gh release view "$tag" --repo "$repo" >/dev/null 2>&1; then
  gh release create "$tag" --repo "$repo" --verify-tag --target "$release_sha" --title "$tag" --notes-file "$notes"
fi
gh issue close 3 --repo "$repo" --comment "Published $tag with matching manifest version and release notes."
