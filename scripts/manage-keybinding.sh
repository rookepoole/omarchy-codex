#!/usr/bin/env bash
set -euo pipefail

action="${1:-}"
bindings_file="${OMARCHY_CODEX_BINDINGS_FILE:-${HOME}/.config/hypr/bindings.lua}"
begin_marker='-- BEGIN OMARCHY CODEX (managed by omarchy-codex)'
end_marker='-- END OMARCHY CODEX'

die() {
  printf 'manage-keybinding: %s\n' "$*" >&2
  exit 1
}

strip_block() {
  local source_file="$1"
  local destination_file="$2"
  awk -v begin="${begin_marker}" -v end="${end_marker}" '
    $0 == begin { managed = 1; next }
    $0 == end { managed = 0; next }
    !managed { print }
  ' "${source_file}" >"${destination_file}"
}

validate_live_config() {
  local before="$1"
  command -v hyprctl >/dev/null 2>&1 || return 0
  [[ -n "${HYPRLAND_INSTANCE_SIGNATURE:-}" ]] || return 0

  hyprctl reload >/dev/null
  local after
  after="$(hyprctl configerrors 2>&1 || true)"
  if [[ "${after}" != "${before}" ]]; then
    printf 'Hyprland validation changed after the Codex keybinding edit.\n' >&2
    printf '%s\n' "${after}" >&2
    return 1
  fi
}

case "${action}" in
  install|remove) ;;
  *) die "usage: manage-keybinding.sh install|remove" ;;
esac

if [[ "${action}" == remove && ! -e "${bindings_file}" ]]; then
  printf 'No managed Codex shortcut was present.\n'
  exit 0
fi

install -d -m 700 "$(dirname "${bindings_file}")"
temporary="$(mktemp "${bindings_file}.tmp.XXXXXX")"
backup="$(mktemp "${bindings_file}.backup.XXXXXX")"
trap 'rm -f "${temporary}" "${backup}"' EXIT

file_existed=0
original_mode=600
if [[ -f "${bindings_file}" ]]; then
  file_existed=1
  original_mode="$(stat -c '%a' "${bindings_file}")"
  begin_count="$(grep -Fxc -- "${begin_marker}" "${bindings_file}" || true)"
  end_count="$(grep -Fxc -- "${end_marker}" "${bindings_file}" || true)"
  if [[ "${begin_count}" != "${end_count}" || "${begin_count}" -gt 1 ]]; then
    die "refusing to edit malformed or duplicate managed markers in ${bindings_file}"
  fi
  cp -p "${bindings_file}" "${backup}"
  strip_block "${bindings_file}" "${temporary}"
else
  : >"${backup}"
  : >"${temporary}"
fi

if [[ "${action}" == install ]]; then
  if [[ -s "${temporary}" ]] && [[ -n "$(tail -c 1 "${temporary}" 2>/dev/null || true)" ]]; then
    printf '\n' >>"${temporary}"
  fi
  cat >>"${temporary}" <<'LUA'
-- BEGIN OMARCHY CODEX (managed by omarchy-codex)
-- Replaces Omarchy's default ChatGPT web shortcut with the graphical Codex app.
hl.unbind("SUPER + SHIFT + A")
o.bind("SUPER + SHIFT + A", "Codex", { launch = "omarchy-codex launch" })
-- END OMARCHY CODEX
LUA
fi

before_errors=''
if command -v hyprctl >/dev/null 2>&1 && [[ -n "${HYPRLAND_INSTANCE_SIGNATURE:-}" ]]; then
  before_errors="$(hyprctl configerrors 2>&1 || true)"
fi

chmod "${original_mode}" "${temporary}"
mv -f "${temporary}" "${bindings_file}"

if ! validate_live_config "${before_errors}"; then
  if (( file_existed )); then
    cp -p "${backup}" "${bindings_file}"
  else
    rm -f "${bindings_file}"
  fi
  if command -v hyprctl >/dev/null 2>&1; then
    hyprctl reload >/dev/null 2>&1 || true
  fi
  die "rolled back the keybinding edit"
fi

if [[ "${action}" == install ]]; then
  printf 'Installed Super+Shift+A graphical Codex shortcut.\n'
else
  printf 'Removed the managed Codex shortcut.\n'
fi
