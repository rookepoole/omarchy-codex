# Maintainer: Rooke Poole <rookepoole@users.noreply.github.com>

pkgname=omarchy-codex
pkgver=26.901.41600
pkgrel=1
pkgdesc="OpenAI's graphical ChatGPT desktop app with Codex, packaged for Omarchy"
arch=('x86_64' 'aarch64')
url="https://learn.chatgpt.com/docs/linux/linux-app"
license=('custom')

depends=(
  'alsa-lib'
  'at-spi2-core'
  'bash'
  'cairo'
  'dbus'
  'expat'
  'gcc-libs'
  'gdk-pixbuf2'
  'glib2'
  'glibc'
  'gtk3'
  'libcups'
  'libdrm'
  'libglvnd'
  'libnotify'
  'libsecret'
  'libusb'
  'libx11'
  'libxcb'
  'libxcomposite'
  'libxdamage'
  'libxext'
  'libxfixes'
  'libxkbcommon'
  'libxrandr'
  'mesa'
  'nspr'
  'nss'
  'pango'
  'systemd-libs'
  'xdg-utils'
  'xz'
)

optdepends=(
  'git: Codex project workflows'
  'gnome-keyring: secure desktop credential storage'
)

makedepends=('libarchive')
provides=('chatgpt' 'openai-codex-desktop')
conflicts=('chatgpt' 'openai-codex-desktop')
options=('!debug' '!strip')

_deb_x86_64="chatgpt_${pkgver}_amd64.deb"
_deb_aarch64="chatgpt_${pkgver}_arm64.deb"
source=('omarchy-codex' 'chatgpt.desktop')
source_x86_64=(
  "${_deb_x86_64}::https://persistent.oaistatic.com/codex-app-prod/linux/deb/pool/main/c/chatgpt/chatgpt_${pkgver}_amd64.deb"
)
source_aarch64=(
  "${_deb_aarch64}::https://persistent.oaistatic.com/codex-app-prod/linux/deb/pool/main/c/chatgpt/chatgpt_${pkgver}_arm64.deb"
)
noextract=("${_deb_x86_64}" "${_deb_aarch64}")
sha256sums=(
  '3121980b5e27919c9f9b459c5facf280968f6a17a935aa03843d9ea6d0f4afdf'
  '274e5eaa174afd5b5bd61802f7cb5984f03dd7e3fb2f3760536e114ee706b022'
)
sha256sums_x86_64=('15cf422a77e8f28a7553d3180b8c72784a994438a141784c82d72cde93efca77')
sha256sums_aarch64=('8d5141b299ca593255fa25760895e84375937cc305197528c822dfa71ac2a3bf')

package() {
  cd "${srcdir}"

  local deb_var="_deb_${CARCH}"
  local deb="${!deb_var}"

  bsdtar -xOf "${deb}" data.tar.xz |
    bsdtar --no-same-owner -xf - -C "${pkgdir}"

  rm -f "${pkgdir}/usr/bin/chatgpt"
  install -Dm755 "${srcdir}/omarchy-codex" "${pkgdir}/usr/bin/omarchy-codex"
  ln -s omarchy-codex "${pkgdir}/usr/bin/chatgpt"

  install -Dm644 "${srcdir}/chatgpt.desktop" \
    "${pkgdir}/usr/share/applications/chatgpt.desktop"
  install -Dm644 "${pkgdir}/usr/share/doc/chatgpt/copyright" \
    "${pkgdir}/usr/share/licenses/${pkgname}/copyright"

  rm -rf "${pkgdir}/usr/share/doc" "${pkgdir}/usr/share/lintian"
}
