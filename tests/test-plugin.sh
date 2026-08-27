#!/usr/bin/env bash
set -euo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
manifest="${root}/manifest.json"
qml="${root}/CodexPanel.qml"

fail() {
  printf 'FAIL: %s\n' "$*" >&2
  exit 1
}

jq -e '
  .schemaVersion == 1 and
  .id == "io.github.rookepoole.omarchy-codex" and
  .version == "0.1.9" and
  .kinds == ["bar-widget"] and
  .entryPoints.barWidget == "CodexPanel.qml" and
  .barWidget.allowMultiple == false and
  .barWidget.defaultSection == "right"
' "${manifest}" >/dev/null || fail 'marketplace manifest contract'

[[ -f "${qml}" ]] || fail 'manifest entry point exists'
grep -Fq 'moduleName: "io.github.rookepoole.omarchy-codex"' "${qml}" || fail 'plugin module id'
grep -Fq 'command -v omarchy-codex' "${qml}" || fail 'non-invasive installed-app detection'
grep -Fq 'bar.run("omarchy-codex launch")' "${qml}" || fail 'graphical app launch action'
grep -Fq 'label: "Review available updates"' "${qml}" || fail 'safe release-review action label'
grep -Fq 'bar.run("omarchy-codex update")' "${qml}" || fail 'safe release-review action'
grep -Fq 'omarchy-codex doctor' "${qml}" || fail 'diagnostic action'

if grep -nE '(sudo|pacman|makepkg|install[.]sh|uninstall[.]sh|rm[[:space:]])' "${qml}"; then
  fail 'panel must not manage the application installation'
fi
if grep -nE '(OPENAI_API_KEY|api[_-]?key)' "${manifest}" "${qml}"; then
  fail 'plugin must not introduce an API-key path'
fi

printf 'PASS Omarchy plugin manifest and non-invasive panel boundary\n'
