#!/usr/bin/env bash
set -euo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
omarchy="${OMARCHY_SOURCE:-${root}/../omarchy-upstream-current-20260825}"

[[ -f "${omarchy}/default/hypr/bindings/applications.lua" ]]
grep -Fq 'o.bind("SUPER + SHIFT + A", "ChatGPT", { webapp = "https://chatgpt.com" })' \
  "${omarchy}/default/hypr/bindings/applications.lua"
grep -Fq 'function o.bind(keys, description, dispatcher, options)' \
  "${omarchy}/default/hypr/helpers.lua"
grep -Fq 'return "uwsm-app -- " .. command' "${omarchy}/default/hypr/helpers.lua"
grep -Fq 'hl.unbind("SUPER + SHIFT + A")' "${root}/scripts/manage-keybinding.sh"
grep -Fq 'o.bind("SUPER + SHIFT + A", "Codex", { launch = "omarchy-codex launch" })' \
  "${root}/scripts/manage-keybinding.sh"
printf 'PASS integration matches current Omarchy keybinding contract\n'
