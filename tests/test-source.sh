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
  "${root}/tests/test-installed-package-detection.sh" \
  "${root}/tests/test-release-bundle.sh" \
  "${root}/tests/test-upstream.sh" \
  "${root}/tests/test-current-omarchy.sh"; do
  bash -n "${script}" || fail "bash syntax: ${script}"
done

grep -Fq 'pkgver=26.820.60940' "${root}/PKGBUILD" || fail 'pinned OpenAI app version'
# These assertions intentionally match literal PKGBUILD variable references.
# shellcheck disable=SC2016
grep -Fq 'chatgpt_${pkgver}_amd64.deb' "${root}/PKGBUILD" || fail 'versioned x86_64 source'
# shellcheck disable=SC2016
grep -Fq 'chatgpt_${pkgver}_arm64.deb' "${root}/PKGBUILD" || fail 'versioned ARM64 source'
# shellcheck disable=SC2016
grep -Fq '/pool/main/c/chatgpt/chatgpt_${pkgver}_amd64.deb' "${root}/PKGBUILD" || fail 'pinned x86_64 pool URL'
# shellcheck disable=SC2016
grep -Fq '/pool/main/c/chatgpt/chatgpt_${pkgver}_arm64.deb' "${root}/PKGBUILD" || fail 'pinned ARM64 pool URL'
grep -Fq '31d956a8c6c515f8d87e0b7acd9ec919f7e685ba59331b4b97aa45f853afdfd7' "${root}/PKGBUILD" || fail 'x86_64 checksum'
grep -Fq '8f4dacbff5f054a4f69c2a021f1396c57976972829a61041febac1b423f27c86' "${root}/PKGBUILD" || fail 'ARM64 checksum'
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

checkout_sha='3d3c42e5aac5ba805825da76410c181273ba90b1'
check_checkout_workflow() {
  local workflow="$1"
  awk -v expected="actions/checkout@${checkout_sha}" '
    function finish_checkout() {
      if (in_checkout && !credentials_disabled) {
        invalid = 1
      }
      in_checkout = 0
    }
    function indentation(line) {
      match(line, /[^ ]/)
      return RSTART ? RSTART - 1 : length(line)
    }
    /^[[:space:]]*-[[:space:]]+uses:[[:space:]]+actions\/checkout@/ {
      finish_checkout()
      in_checkout = 1
      credentials_disabled = 0
      checkout_indent = indentation($0)
      reference = $0
      sub(/^[[:space:]]*-[[:space:]]+uses:[[:space:]]+/, "", reference)
      sub(/[[:space:]]+#.*$/, "", reference)
      if (reference != expected) {
        invalid = 1
      }
      checkout_count++
      next
    }
    in_checkout &&
      /^[[:space:]]*-[[:space:]]+/ &&
      indentation($0) <= checkout_indent {
      finish_checkout()
    }
    in_checkout &&
      /^[[:space:]]+persist-credentials:[[:space:]]*false([[:space:]]*(#.*)?)?$/ {
      credentials_disabled = 1
    }
    END {
      finish_checkout()
      if (invalid || checkout_count != 1) {
        exit 1
      }
    }
  ' "${workflow}" || fail "unsafe checkout action in ${workflow}"
}
for workflow in \
  "${root}/.github/workflows/release.yml" \
  "${root}/.github/workflows/test.yml"; do
  check_checkout_workflow "${workflow}"
done
grep -A1 '^permissions:$' "${root}/.github/workflows/test.yml" |
  grep -Fq 'contents: read' || fail 'test workflow token is not read-only'
if grep -Eq '^[[:space:]]*permissions:[[:space:]]*write-all|^[[:space:]]+[a-z-]+:[[:space:]]*write([[:space:]]*(#.*)?)?$' \
  "${root}/.github/workflows/test.yml"; then
  fail 'test workflow grants write permission'
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
