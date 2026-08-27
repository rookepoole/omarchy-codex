#!/usr/bin/env bash
set -euo pipefail

PROJECT_VERSION=0.1.9

die() {
  printf 'omarchy-codex install: %s\n' "$*" >&2
  exit 1
}

is_project_checkout() {
  [[ -f "$1/PKGBUILD" && -x "$1/scripts/manage-keybinding.sh" ]]
}

resolve_source() {
  local candidate=''
  if [[ -n "${BASH_SOURCE[0]:-}" && -e "${BASH_SOURCE[0]}" ]]; then
    candidate="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  fi
  if [[ -n "${candidate}" ]] && is_project_checkout "${candidate}"; then
    printf '%s\n' "${candidate}"
    return
  fi

  die "run install.sh from a project checkout or checksummed release bundle"
}

[[ ${EUID} -ne 0 ]] || die "run this as your normal Omarchy user, not root"
[[ -r /etc/os-release ]] || die "cannot identify this Linux distribution"
# shellcheck disable=SC1091
source /etc/os-release
if [[ "${ID:-}" != arch && " ${ID_LIKE:-} " != *' arch '* ]]; then
  die "this package targets Omarchy on Arch Linux"
fi
if ! command -v omarchy-version >/dev/null 2>&1 && [[ ! -d /usr/share/omarchy ]]; then
  [[ "${OMARCHY_CODEX_ALLOW_PLAIN_ARCH:-0}" == 1 ]] ||
    die "Omarchy was not detected (set OMARCHY_CODEX_ALLOW_PLAIN_ARCH=1 only for plain-Arch testing)"
fi
case "$(uname -m)" in
  x86_64|aarch64|arm64) ;;
  *) die "only x86_64 and ARM64 are supported by OpenAI's Linux preview" ;;
esac
command -v pacman >/dev/null 2>&1 || die "pacman is required"
command -v sudo >/dev/null 2>&1 || die "sudo is required"

package_installed_exactly() {
  # Consume pacman's complete output. A quiet grep exits at the first match,
  # which can give pacman SIGPIPE and turn a true match into failure under
  # `set -o pipefail` on systems with a large installed-package list.
  pacman -Qq | awk -v expected="$1" '
    $0 == expected { found = 1 }
    END { exit !found }
  '
}

if package_installed_exactly openai-codex-desktop; then
  die "openai-codex-desktop is installed; remove it before installing omarchy-codex"
fi
if package_installed_exactly chatgpt; then
  die "a conflicting chatgpt package is installed; remove it before installing omarchy-codex"
fi
if ! package_installed_exactly omarchy-codex; then
  existing_chatgpt="$(command -v chatgpt 2>/dev/null || true)"
  if [[ -n "${existing_chatgpt}" || -e /usr/lib/chatgpt/ChatGPT ]]; then
    existing_chatgpt="${existing_chatgpt:-/usr/lib/chatgpt/ChatGPT}"
    owner="$(pacman -Qo "${existing_chatgpt}" 2>/dev/null || printf 'not owned by pacman')"
    die "existing ChatGPT installation detected at ${existing_chatgpt} (${owner}); refusing to replace it"
  fi
fi

project_dir="$(resolve_source)"
is_project_checkout "${project_dir}" || die "invalid project checkout: ${project_dir}"

printf 'Installing Omarchy Codex %s (OpenAI app %s)...\n' \
  "${PROJECT_VERSION}" "$(<"${project_dir}/APP_VERSION")"
sudo pacman -S --needed --noconfirm base-devel git libarchive

cache_root="${XDG_CACHE_HOME:-${HOME}/.cache}/omarchy-codex"
install -d -m 755 "$(dirname "${cache_root}")"
build_dir="$(mktemp -d "${cache_root}.build.XXXXXX")"
cleanup() {
  case "${build_dir}" in
    "${cache_root}.build."*) rm -rf -- "${build_dir}" ;;
    *) printf 'Refusing to clean unexpected build path: %s\n' "${build_dir}" >&2 ;;
  esac
}
trap cleanup EXIT
install -d -m 755 "${cache_root}/sources" "${cache_root}/packages"
cp "${project_dir}/PKGBUILD" "${project_dir}/omarchy-codex" "${project_dir}/chatgpt.desktop" "${build_dir}/"

(
  cd "${build_dir}"
  SRCDEST="${cache_root}/sources" PKGDEST="${cache_root}/packages" \
    makepkg --syncdeps --install --noconfirm --needed --cleanbuild
)

expected_version="$(<"${project_dir}/APP_VERSION")"
metadata=/usr/lib/chatgpt/resources/linux-package-metadata.json
[[ -x /usr/lib/chatgpt/ChatGPT ]] || die "package installed without the graphical app binary"
[[ -f "${metadata}" ]] || die "package installed without OpenAI version metadata"
grep -Fq "\"version\": \"${expected_version}\"" "${metadata}" ||
  die "installed OpenAI app version does not match ${expected_version}"

"${project_dir}/scripts/manage-keybinding.sh" install
printf '\nInstalled the graphical Codex app.\n'
printf 'Open Apps and choose Codex, or press Super+Shift+A.\n'
printf 'Sign in with ChatGPT in the browser; no API key is needed.\n'
printf 'No reboot is required for this app-only install.\n'
