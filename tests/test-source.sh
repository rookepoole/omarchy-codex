#!/usr/bin/env bash
set -euo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
fail() {
  printf 'FAIL: %s\n' "$*" >&2
  exit 1
}

for script in \
  "${root}/install.sh" \
  "${root}/uninstall.sh" \
  "${root}/omarchy-codex" \
  "${root}/scripts/build-release-bundle.sh" \
  "${root}/scripts/manage-keybinding.sh" \
  "${root}/tests/test-source.sh" \
  "${root}/tests/test-launcher.sh" \
  "${root}/tests/test-keybinding.sh" \
  "${root}/tests/test-release-bundle.sh" \
  "${root}/tests/test-upstream.sh" \
  "${root}/tests/test-current-omarchy.sh"; do
  bash -n "${script}" || fail "bash syntax: ${script}"
done

grep -Fq 'pkgver=26.818.61809' "${root}/PKGBUILD" || fail 'pinned OpenAI app version'
# These assertions intentionally match literal PKGBUILD variable references.
# shellcheck disable=SC2016
grep -Fq 'chatgpt_${pkgver}_amd64.deb' "${root}/PKGBUILD" || fail 'versioned x86_64 source'
# shellcheck disable=SC2016
grep -Fq 'chatgpt_${pkgver}_arm64.deb' "${root}/PKGBUILD" || fail 'versioned ARM64 source'
# shellcheck disable=SC2016
grep -Fq '/pool/main/c/chatgpt/chatgpt_${pkgver}_amd64.deb' "${root}/PKGBUILD" || fail 'pinned x86_64 pool URL'
# shellcheck disable=SC2016
grep -Fq '/pool/main/c/chatgpt/chatgpt_${pkgver}_arm64.deb' "${root}/PKGBUILD" || fail 'pinned ARM64 pool URL'
grep -Fq '1bba62a6dbd2d49975c62850d8eddaad605da193557b194982225e56b1941891' "${root}/PKGBUILD" || fail 'x86_64 checksum'
grep -Fq 'a538eab08ff9cb50d8c83471d3b491dd3c44a79953a1f8a80ec54a2bdb25a13a' "${root}/PKGBUILD" || fail 'ARM64 checksum'
grep -Fq 'Exec=omarchy-codex launch %U' "${root}/chatgpt.desktop" || fail 'graphical desktop entry'
grep -Fq 'Terminal=false' "${root}/chatgpt.desktop" || fail 'desktop entry must not open a terminal'
grep -Fq 'existing ChatGPT installation detected' "${root}/install.sh" || fail 'existing-app replacement guard'
# Match the literal PKGBUILD package-directory expression.
# shellcheck disable=SC2016
if grep -Fq '"${pkgdir}/usr/bin/codex"' "${root}/PKGBUILD"; then
  fail 'package must not replace Omarchy Codex CLI'
fi
wrapper_sha="$(sha256sum "${root}/omarchy-codex" | awk '{print $1}')"
desktop_sha="$(sha256sum "${root}/chatgpt.desktop" | awk '{print $1}')"
grep -Fq "'${wrapper_sha}'" "${root}/PKGBUILD" || fail 'launcher checksum does not match PKGBUILD'
grep -Fq "'${desktop_sha}'" "${root}/PKGBUILD" || fail 'desktop-entry checksum does not match PKGBUILD'

if grep -RniE --exclude='test-source.sh' \
  '(OPENAI_API_KEY|--with-api-key|api_key[[:space:]]*=)' "${root}"; then
  fail 'runtime source contains an API-key path'
fi
if grep -ni -- '--no-sandbox' \
  "${root}/install.sh" \
  "${root}/uninstall.sh" \
  "${root}/omarchy-codex" \
  "${root}/PKGBUILD" \
  "${root}/scripts/manage-keybinding.sh"; then
  fail 'Chromium sandbox must not be disabled'
fi
if find "${root}" -type f \( -name '*.deb' -o -name '*.pkg.tar.*' \) -print -quit | grep -q .; then
  fail 'proprietary package payload present in source tree'
fi

if command -v desktop-file-validate >/dev/null 2>&1; then
  desktop-file-validate "${root}/chatgpt.desktop" || fail 'desktop entry validation'
fi
if command -v shellcheck >/dev/null 2>&1; then
  shellcheck \
    "${root}/install.sh" \
    "${root}/uninstall.sh" \
    "${root}/omarchy-codex" \
    "${root}/scripts/manage-keybinding.sh" || fail 'shellcheck'
fi

printf 'PASS source invariants\n'
