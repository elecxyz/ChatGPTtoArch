# Maintainer: Repository contributors

pkgname=chatgpt-desktop-bin
pkgver=26.820.60940
pkgrel=1
pkgdesc='Official ChatGPT/Codex desktop app for Linux (repacked from the OpenAI Debian package)'
arch=('x86_64')
url='https://chatgpt.com/download'
license=('custom')
depends=(
  'alsa-lib'
  'at-spi2-core'
  'cairo'
  'dbus'
  'expat'
  'gcc-libs'
  'gdk-pixbuf2'
  'glib2'
  'glibc'
  'graphite'
  'gtk3'
  'libcups'
  'libdrm'
  'libglvnd'
  'libnotify'
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
  'openssl'
  'pango'
  'systemd-libs'
  'sh'
  'xdg-utils'
)
makedepends=('binutils')
optdepends=(
  'apparmor: support for the bundled user-namespace profile'
  'git: Git repository integration'
  'gnome-keyring: Secret Service credential storage under GNOME'
  'kde-cli-tools: file deletion support under KDE Plasma'
  'libsecret: Secret Service credential storage'
  'pipewire: screen sharing under Wayland'
  'python: bundled Python-based tools and skills'
)
provides=("chatgpt=$pkgver" "openai-codex-desktop=$pkgver")
conflicts=('chatgpt' 'openai-codex-desktop')
replaces=('openai-codex-desktop')
options=('!strip' '!debug')

_repo_url='https://persistent.oaistatic.com/codex-app-prod/linux/deb'
source_x86_64=(
  "chatgpt_${pkgver}_amd64.deb::${_repo_url}/pool/main/c/chatgpt/chatgpt_${pkgver}_amd64.deb"
)
sha256sums_x86_64=('31d956a8c6c515f8d87e0b7acd9ec919f7e685ba59331b4b97aa45f853afdfd7')

package() {
  local deb="$srcdir/chatgpt_${pkgver}_amd64.deb"
  local data_archive="$srcdir/data.tar.xz"

  install -d "$pkgdir"

  # Extract only the application payload. Debian control metadata and its
  # post-install/remove scripts are deliberately excluded.
  ar p "$deb" data.tar.xz > "$data_archive"
  bsdtar --no-same-owner -xJf "$data_archive" -C "$pkgdir"
  rm "$data_archive"

  # Arch packages with a custom license install it in this standard location.
  install -Dm644 \
    "$pkgdir/usr/share/doc/chatgpt/copyright" \
    "$pkgdir/usr/share/licenses/$pkgname/LICENSE"

  # These directories are only useful to Debian packaging tools.
  rm -rf \
    "$pkgdir/usr/share/doc/chatgpt" \
    "$pkgdir/usr/share/lintian"
  rmdir "$pkgdir/usr/share/doc" 2>/dev/null || true
}
