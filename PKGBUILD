# Maintainer: Rooke Poole <rookepoole@users.noreply.github.com>

pkgname=omarchy-codex
pkgver=26.818.61809
pkgrel=4
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
  'git: Codex project integration and Omarchy Codex updates'
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
  '0cb69304db72aa4df3fbf69497710da4d100df544cf1cf993750c175d61a14f4'
  '274e5eaa174afd5b5bd61802f7cb5984f03dd7e3fb2f3760536e114ee706b022'
)
sha256sums_x86_64=('1bba62a6dbd2d49975c62850d8eddaad605da193557b194982225e56b1941891')
sha256sums_aarch64=('a538eab08ff9cb50d8c83471d3b491dd3c44a79953a1f8a80ec54a2bdb25a13a')

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
