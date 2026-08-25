#!/usr/bin/env bash
set -euo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
omarchy="${OMARCHY_SOURCE:-${root}/../omarchy-upstream-current-20260825}"
temporary=''
if [[ ! -d "${omarchy}/.git" ]]; then
  temporary="$(mktemp -d)"
  trap 'rm -rf -- "${temporary}"' EXIT
  omarchy="${temporary}/omarchy"
  git clone --quiet --depth 1 --branch quattro https://github.com/basecamp/omarchy.git "${omarchy}"
fi

[[ -f "${omarchy}/default/hypr/bindings/applications.lua" ]]
grep -Fq 'o.bind("SUPER + SHIFT + A", "ChatGPT", { webapp = "https://chatgpt.com" })' \
  "${omarchy}/default/hypr/bindings/applications.lua"
grep -Fq 'function o.bind(keys, description, dispatcher, options)' \
  "${omarchy}/default/hypr/helpers.lua"
grep -Fq 'return "uwsm-app -- " .. command' "${omarchy}/default/hypr/helpers.lua"
grep -Fq '[codex, "-s", "read-only", "-a", "on-request", "app-server"]' \
  "${omarchy}/bin/omarchy-agent-usage-codex"
grep -Fq 'hl.unbind("SUPER + SHIFT + A")' "${root}/scripts/manage-keybinding.sh"
grep -Fq 'o.bind("SUPER + SHIFT + A", "Codex", { launch = "omarchy-codex launch" })' \
  "${root}/scripts/manage-keybinding.sh"
# Match the literal PKGBUILD package-directory expression.
# shellcheck disable=SC2016
if grep -Fq '"${pkgdir}/usr/bin/codex"' "${root}/PKGBUILD"; then
  printf 'FAIL graphical package would replace Omarchy Codex CLI\n' >&2
  exit 1
fi
printf 'PASS integration matches current Omarchy keybinding contract\n'
