#!/usr/bin/env bash
set -euo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
test_root="$(mktemp -d)"
trap 'rm -rf -- "${test_root}"' EXIT
bindings="${test_root}/bindings.lua"
manager="${root}/scripts/manage-keybinding.sh"

printf '%s\n' '-- user content' 'o.bind("SUPER + R", "Run", "runner")' >"${bindings}"
chmod 644 "${bindings}"
OMARCHY_CODEX_BINDINGS_FILE="${bindings}" "${manager}" install >/dev/null
first_hash="$(sha256sum "${bindings}" | awk '{print $1}')"
OMARCHY_CODEX_BINDINGS_FILE="${bindings}" "${manager}" install >/dev/null
second_hash="$(sha256sum "${bindings}" | awk '{print $1}')"
[[ "${first_hash}" == "${second_hash}" ]]
[[ "$(grep -Fc -- '-- BEGIN OMARCHY CODEX' "${bindings}")" == 1 ]]
grep -Fq 'hl.unbind("SUPER + SHIFT + A")' "${bindings}"
grep -Fq 'o.bind("SUPER + SHIFT + A", "Codex", { launch = "omarchy-codex launch" })' "${bindings}"
[[ "$(stat -c '%a' "${bindings}")" == 644 ]]

OMARCHY_CODEX_BINDINGS_FILE="${bindings}" "${manager}" remove >/dev/null
grep -Fq -- '-- user content' "${bindings}"
if grep -Fq -- '-- BEGIN OMARCHY CODEX' "${bindings}"; then
  printf 'FAIL managed keybinding block survived removal\n' >&2
  exit 1
fi

printf '%s\n' '-- BEGIN OMARCHY CODEX (managed by omarchy-codex)' 'user_data()' >"${bindings}"
before="$(sha256sum "${bindings}" | awk '{print $1}')"
if OMARCHY_CODEX_BINDINGS_FILE="${bindings}" "${manager}" install 2>/dev/null; then
  printf 'FAIL malformed markers were accepted\n' >&2
  exit 1
fi
after="$(sha256sum "${bindings}" | awk '{print $1}')"
[[ "${before}" == "${after}" ]]

printf '%s\n' '-- clean baseline' >"${bindings}"
mkdir -p "${test_root}/bin"
cat >"${test_root}/bin/hyprctl" <<'HYPR'
#!/usr/bin/env bash
if [[ ${1:-} == configerrors ]]; then
  count=0
  [[ -f ${HYPR_TEST_COUNT} ]] && count="$(<"${HYPR_TEST_COUNT}")"
  count=$((count + 1))
  printf '%s\n' "${count}" >"${HYPR_TEST_COUNT}"
  (( count > 1 )) && printf 'introduced config error\n'
fi
HYPR
chmod +x "${test_root}/bin/hyprctl"
if PATH="${test_root}/bin:${PATH}" \
  HYPRLAND_INSTANCE_SIGNATURE=test \
  HYPR_TEST_COUNT="${test_root}/hypr-count" \
  OMARCHY_CODEX_BINDINGS_FILE="${bindings}" \
  "${manager}" install >/dev/null 2>&1; then
  printf 'FAIL live Hyprland error did not trigger rollback\n' >&2
  exit 1
fi
[[ "$(<"${bindings}")" == '-- clean baseline' ]]

printf 'PASS keybinding idempotence, preservation, and rollback\n'
