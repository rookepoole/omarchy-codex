#!/usr/bin/env bash
set -euo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
test_root="$(mktemp -d)"
trap 'rm -rf -- "${test_root}"' EXIT

fake_app="${test_root}/ChatGPT"
args_log="${test_root}/args"
cat >"${fake_app}" <<'APP'
#!/usr/bin/env bash
printf '%s\n' "$@" >"${OMARCHY_CODEX_ARGS_LOG}"
APP
chmod +x "${fake_app}" "${root}/omarchy-codex"

run_wrapper() {
  HOME="${test_root}/home" \
    XDG_CONFIG_HOME="${test_root}/config" \
    OMARCHY_CODEX_APP_BINARY="${fake_app}" \
    OMARCHY_CODEX_ARGS_LOG="${args_log}" \
    "${root}/omarchy-codex" "$@"
}

run_launcher() {
  : >"${args_log}"
  run_wrapper launch "$@"
}

XDG_SESSION_TYPE=x11 WAYLAND_DISPLAY='' run_launcher 'codex://login/callback?value=hello world'
[[ "$(<"${args_log}")" == 'codex://login/callback?value=hello world' ]]

WAYLAND_DISPLAY=wayland-1 run_launcher project
mapfile -t args <"${args_log}"
[[ "${args[0]}" == --ozone-platform=wayland ]]
[[ "${args[1]}" == project ]]

run_wrapper scale 1 >/dev/null
WAYLAND_DISPLAY=wayland-1 run_launcher project
mapfile -t args <"${args_log}"
[[ "${args[0]}" == --ozone-platform=wayland ]]
[[ "${args[1]}" == --force-device-scale-factor=1 ]]
[[ "${args[2]}" == project ]]

if run_wrapper scale 0.25 >/dev/null 2>&1; then
  printf 'FAIL accepted an unsafe display scale\n' >&2
  exit 1
fi
run_wrapper scale auto >/dev/null

mkdir -p "${test_root}/config/omarchy-codex"
printf 'wayland\n' >"${test_root}/config/omarchy-codex/rendering"
run_launcher project
mapfile -t args <"${args_log}"
[[ "${args[0]}" == --ozone-platform=wayland ]]
[[ "${args[1]}" == project ]]

printf 'xwayland\n' >"${test_root}/config/omarchy-codex/rendering"
run_launcher
[[ "$(<"${args_log}")" == --ozone-platform=x11 ]]

printf 'broken\n' >"${test_root}/config/omarchy-codex/rendering"
if run_launcher 2>/dev/null; then
  printf 'FAIL invalid rendering mode was accepted\n' >&2
  exit 1
fi

printf 'PASS launcher argument and rendering behavior\n'
