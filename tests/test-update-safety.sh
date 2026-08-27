#!/usr/bin/env bash
set -euo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

fail() {
  printf 'FAIL: %s\n' "$*" >&2
  exit 1
}

runtime_files=(
  "${root}/omarchy-codex"
  "${root}/install.sh"
  "${root}/CodexPanel.qml"
)

if grep -nE '\bgit[[:space:]].*\b(pull|clone|fetch)\b' "${runtime_files[@]}"; then
  fail 'runtime update or install surface acquires mutable remote Git source'
fi
if grep -nE 'install[.]sh.*--update|SOURCE_HOME|git[[:space:]]+-C.*checkout' "${runtime_files[@]}"; then
  fail 'remote source execution path returned'
fi

grep -Fq 'RELEASES_URL="https://github.com/rookepoole/omarchy-codex/releases"' \
  "${root}/omarchy-codex" || fail 'reviewed releases destination'
grep -Fq 'No code will be downloaded or executed.' "${root}/omarchy-codex" ||
  fail 'update behavior is explicit'
grep -Fq 'run install.sh from a project checkout or checksummed release bundle' \
  "${root}/install.sh" || fail 'local-source-only installer'
grep -Fq 'label: "Review available updates"' "${root}/CodexPanel.qml" ||
  fail 'panel communicates non-installing update behavior'

test_root="$(mktemp -d)"
trap 'rm -rf -- "${test_root}"' EXIT
install -d -m 755 "${test_root}/bin"
printf '%s\n' \
  '#!/usr/bin/env bash' \
  'printf "%s\n" "$1" >"${OMARCHY_CODEX_TEST_CAPTURE}"' \
  >"${test_root}/bin/xdg-open"
chmod +x "${test_root}/bin/xdg-open"

OMARCHY_CODEX_TEST_CAPTURE="${test_root}/opened" \
  PATH="${test_root}/bin:${PATH}" "${root}/omarchy-codex" update \
  >"${test_root}/output"
grep -Fxq 'https://github.com/rookepoole/omarchy-codex/releases' \
  "${test_root}/opened" || fail 'update command did not open the releases page'
grep -Fq 'No code will be downloaded or executed.' "${test_root}/output" ||
  fail 'update command did not explain its safe behavior'
if PATH="${test_root}/bin:${PATH}" "${root}/omarchy-codex" update unexpected \
  >"${test_root}/unexpected-output" 2>"${test_root}/unexpected-error"; then
  fail 'update command accepted an unexpected argument'
fi

printf 'PASS update surface cannot pull or execute mutable remote source\n'
