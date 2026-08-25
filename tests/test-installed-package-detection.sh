#!/usr/bin/env bash
set -euo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
test_root="$(mktemp -d)"
trap 'rm -rf -- "${test_root}"' EXIT

sed -n '/^package_installed_exactly()/,/^}/p' "${root}/install.sh" \
  >"${test_root}/package-function.sh"
# shellcheck source=/dev/null
source "${test_root}/package-function.sh"

cat >"${test_root}/pacman" <<'PACMAN'
#!/usr/bin/env bash
set -euo pipefail
[[ "${1:-}" == -Qq ]]
printf 'omarchy-codex\n'
printf 'omarchy-codex-helper\n'
for ((index = 0; index < 50000; index++)); do
  printf 'installed-package-%05d\n' "${index}"
done
PACMAN
chmod +x "${test_root}/pacman"
PATH="${test_root}:${PATH}"

legacy_detection() {
  pacman -Qq | grep -Fxq -- "$1"
}
if legacy_detection omarchy-codex; then
  printf 'FAIL regression fixture did not reproduce the legacy pipefail bug\n' >&2
  exit 1
fi

package_installed_exactly omarchy-codex
if package_installed_exactly chatgpt; then
  printf 'FAIL accepted a package name that was not installed exactly\n' >&2
  exit 1
fi
if package_installed_exactly omarchy-codex-help; then
  printf 'FAIL accepted a partial package-name match\n' >&2
  exit 1
fi
printf 'PASS exact installed-package detection survives a large pacman list\n'
