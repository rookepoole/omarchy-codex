# Maintainer: Rooke Poole <rookepoole@users.noreply.github.com>

pkgname=omarchy-codex
pkgver=26.820.60940
pkgrel=3
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
  '812c58da8836c6aab6bb70c56597bf31765086d763c097aacc81537893f4fb06'
  '274e5eaa174afd5b5bd61802f7cb5984f03dd7e3fb2f3760536e114ee706b022'
)
sha256sums_x86_64=('31d956a8c6c515f8d87e0b7acd9ec919f7e685ba59331b4b97aa45f853afdfd7')
sha256sums_aarch64=('8f4dacbff5f054a4f69c2a021f1396c57976972829a61041febac1b423f27c86')

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
