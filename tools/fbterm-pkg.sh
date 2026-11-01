#!/bin/bash
set -e
P=~/.local/var/pmbootstrap/cache_git/pmaports
mkdir -p $P/main/fbterm
cat > $P/main/fbterm/APKBUILD <<'EOF'
# Local package for the S10 fork: fbterm with Debian's patches
pkgname=fbterm
pkgver=1.7
pkgrel=0
_debrel=5
pkgdesc="Fast framebuffer terminal emulator with TrueType fonts"
url="https://salsa.debian.org/debian/fbterm"
arch="aarch64"
license="GPL-2.0-or-later"
makedepends="autoconf automake fontconfig-dev freetype-dev ncurses"
options="!check"
source="https://deb.debian.org/debian/pool/main/f/fbterm/fbterm_$pkgver.orig.tar.gz
	https://deb.debian.org/debian/pool/main/f/fbterm/fbterm_$pkgver-$_debrel.debian.tar.xz
	"
builddir="$srcdir/fbterm-$pkgver"

prepare() {
	default_prepare
	local p
	for p in $(cat "$srcdir"/debian/patches/series); do
		msg "applying Debian patch $p"
		patch -p1 -i "$srcdir"/debian/patches/"$p"
	done
	autoreconf -fi
}

build() {
	./configure \
		--prefix=/usr \
		--sysconfdir=/etc \
		--disable-vesa \
		--disable-gpm
	make
}

package() {
	make DESTDIR="$pkgdir" install
}

sha512sums="
3d3135bf289ca39824958c50cc36ee7dd4fce69e9cfb6ea3a657a72159794b73a1fcfd196b899fcc5d3644f57fa265c03edb4c18db175d739c3507482b8e8acc  fbterm_1.7.orig.tar.gz
4a8d2f999d95e334c5e6ac081e538d414f6285656db622bd33572eec46e15d94192bbf336c48d2172007f5b8e73b056f9571ae018d17d064523cf8e819623b2b  fbterm_1.7-5.debian.tar.xz
"
EOF
cd $P
git add main/fbterm/APKBUILD
git -c user.name="khan" -c user.email="khan@localhost" commit -qm "fbterm: new local package (Debian 1.7-5 patches)"
git log -1 --oneline
