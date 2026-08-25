#!/usr/bin/env bash
set -euo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
output_requested="${1:-${root}/dist}"
version="$(<"${root}/VERSION")"
[[ "${version}" =~ ^[0-9]+[.][0-9]+[.][0-9]+$ ]] || {
  printf 'Invalid VERSION: %s\n' "${version}" >&2
  exit 1
}

install -d -m 755 "${output_requested}"
output="$(cd "${output_requested}" && pwd)"
name="omarchy-codex-${version}"
archive="${output}/${name}.tar.gz"
checksum="${archive}.sha256"
staging="$(mktemp -d)"
trap 'rm -rf -- "${staging}"' EXIT
bundle="${staging}/${name}"

for file in \
  APP_VERSION CHANGELOG.md LICENSE PKGBUILD README.md SECURITY.md VERSION \
  chatgpt.desktop; do
  install -Dm644 "${root}/${file}" "${bundle}/${file}"
done
for file in install.sh omarchy-codex uninstall.sh scripts/manage-keybinding.sh; do
  install -Dm755 "${root}/${file}" "${bundle}/${file}"
done
while IFS= read -r file; do
  relative="${file#"${root}/"}"
  install -Dm644 "${file}" "${bundle}/${relative}"
done < <(find "${root}/docs" -maxdepth 1 -type f -name '*.md' -print | sort)

tar --sort=name --mtime="@${SOURCE_DATE_EPOCH:-0}" \
  --owner=0 --group=0 --numeric-owner -C "${staging}" -czf "${archive}" "${name}"
(
  cd "${output}"
  sha256sum "$(basename "${archive}")" >"$(basename "${checksum}")"
)
printf '%s\n%s\n' "${archive}" "${checksum}"
