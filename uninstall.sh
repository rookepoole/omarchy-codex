#!/usr/bin/env bash
set -euo pipefail

project_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
purge=0
[[ "${1:-}" == --purge ]] && purge=1

"${project_dir}/scripts/manage-keybinding.sh" remove

if command -v pacman >/dev/null 2>&1 && pacman -Q omarchy-codex >/dev/null 2>&1; then
  sudo pacman -R --noconfirm omarchy-codex
fi

if (( purge )); then
  config_dir="${XDG_CONFIG_HOME:-${HOME}/.config}/omarchy-codex"
  source_dir="${XDG_DATA_HOME:-${HOME}/.local/share}/omarchy-codex"
  case "${config_dir}" in
    */.config/omarchy-codex) rm -rf -- "${config_dir}" ;;
    *) printf 'Refusing to purge unexpected config path: %s\n' "${config_dir}" >&2 ;;
  esac
  case "${source_dir}" in
    */.local/share/omarchy-codex) rm -rf -- "${source_dir}" ;;
    *) printf 'Refusing to purge unexpected source path: %s\n' "${source_dir}" >&2 ;;
  esac
  printf 'Removed Omarchy Codex wrapper settings and managed source.\n'
else
  printf 'Preserved settings and all ChatGPT/Codex sign-in data.\n'
fi
printf 'Uninstalled Omarchy Codex.\n'
