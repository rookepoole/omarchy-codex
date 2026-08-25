#!/usr/bin/env bash
set -euo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
test_root="$(mktemp -d)"
trap 'rm -rf -- "${test_root}"' EXIT
version="$(<"${root}/VERSION")"
name="omarchy-codex-${version}"

"${root}/scripts/build-release-bundle.sh" "${test_root}/dist" >/dev/null
"${root}/scripts/build-release-bundle.sh" "${test_root}/dist-second" >/dev/null
cmp "${test_root}/dist/${name}.tar.gz" "${test_root}/dist-second/${name}.tar.gz"
(
  cd "${test_root}/dist"
  sha256sum -c "${name}.tar.gz.sha256" >/dev/null
)
if tar -tzf "${test_root}/dist/${name}.tar.gz" | grep -Eq '[.]deb$|[.]pkg[.]tar'; then
  printf 'FAIL proprietary or pacman payload present in release bundle\n' >&2
  exit 1
fi
tar -xzf "${test_root}/dist/${name}.tar.gz" -C "${test_root}"
[[ "$(<"${test_root}/${name}/VERSION")" == "${version}" ]]
[[ -x "${test_root}/${name}/install.sh" ]]
[[ -x "${test_root}/${name}/omarchy-codex" ]]
[[ -x "${test_root}/${name}/scripts/manage-keybinding.sh" ]]
[[ -f "${test_root}/${name}/docs/core-workflow-check.md" ]]
printf 'PASS payload-free release bundle and checksum\n'
