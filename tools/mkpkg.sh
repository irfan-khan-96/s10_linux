#!/bin/bash
# Create device/downstream/s10-terminal in the fork from the working phone setup.
set -e
SP=$(dirname "$0")
CFG=/mnt/c/Users/irfan/Desktop/s10-postmarketos/phone-config
P=~/.local/var/pmbootstrap/cache_git/pmaports/device/downstream/s10-terminal
rm -rf "$P"; mkdir -p "$P"; cd "$P"

# programs (now in /usr/bin)
cp "$SP/s10-osk" s10-osk
cp "$SP/s10-idle-blank" s10-idle-blank
cp "$CFG/usr/local/bin/s10-touch-absfix" s10-touch-absfix
sed 's|/usr/local/bin/|/usr/bin/|g' "$SP/osk-start.sh" > s10-osk-start

cat > s10-term <<'EOF'
#!/bin/sh
# Terminal session for tty1: fbterm + tmux above the on-screen keyboard.
[ -f "$HOME/.fbtermrc" ] || cp /usr/share/s10-terminal/fbtermrc "$HOME/.fbtermrc"
export TERM=fbterm
export FBTERM_RESERVE_BOTTOM="${FBTERM_RESERVE_BOTTOM:-1100}"   # height of s10-osk
exec fbterm -- tmux new -A -s main
EOF
cp "$CFG/home/farmer/.fbtermrc" fbtermrc
cp "$CFG/home/farmer/.tmux.conf" tmux.conf

# boot scripts (local.d), paths moved to /usr/bin
for f in 10-firewall 20-display-on 30-usb-dhcp 40-s10-tuning; do
	cp "$CFG/etc/local.d/$f.start" "$f.start"
done
sed -i 's|^IPT=/usr/sbin/iptables-legacy$|LAN=192.168.178.0/24   # home network allowed to reach SSH and the share\nIPT=/usr/sbin/iptables-legacy|; s|192\.168\.178\.0/24 -p|$LAN -p|g' 10-firewall.start
printf '#!/bin/sh\npidof -x s10-idle-blank >/dev/null || setsid /usr/bin/s10-idle-blank >/dev/null 2>&1 < /dev/null &\n' > 50-s10-idle-blank.start
printf '#!/bin/sh\n# on-screen keyboard in the strip fbterm leaves free (FBTERM_RESERVE_BOTTOM)\nsetsid /usr/bin/s10-osk > /tmp/osk.log 2>&1 < /dev/null &\n' > 60-s10-osk.start

sed 's|/usr/local/bin/|/usr/bin/|' "$CFG/etc/udev/rules.d/90-s10-touch-absfix.rules" > 90-s10-touch-absfix.rules
cp "$CFG/etc/conf.d/unudhcpd.rndis0" unudhcpd.rndis0.confd
cp "$CFG/etc/NetworkManager/conf.d/10-s10-wifi-powersave-off.conf" wifi-powersave-off.conf
grep -v '^AllowUsers' "$CFG/etc/ssh/sshd_config.d/10-hardening.conf" > sshd-hardening.conf

cat > s10-terminal.post-install <<'EOF'
#!/bin/sh
# Wire up services, the tty1 terminal and the phone user's groups.
user=$(getent passwd 10000 | cut -d: -f1)
rc-update -q add local default
rc-update -q add msm-fb-refresher default
rc-update -q del unudhcpd.usb0 boot 2>/dev/null
rc-update -q add unudhcpd.rndis0 default
if [ -n "$user" ]; then
	for g in video input audio; do addgroup "$user" "$g" 2>/dev/null; done
	[ -f /etc/inittab.orig ] || cp /etc/inittab /etc/inittab.orig
	sed -i "s|^tty1::respawn:.*|tty1::respawn:/bin/su -l $user -c /usr/bin/s10-term|" /etc/inittab
fi
exit 0
EOF
cp s10-terminal.post-install s10-terminal.post-upgrade

files="s10-osk s10-idle-blank s10-touch-absfix s10-osk-start s10-term fbtermrc tmux.conf
10-firewall.start 20-display-on.start 30-usb-dhcp.start 40-s10-tuning.start
50-s10-idle-blank.start 60-s10-osk.start 90-s10-touch-absfix.rules unudhcpd.rndis0.confd
wifi-powersave-off.conf sshd-hardening.conf"

{
cat <<'EOF'
# Local package for the S10 fork: terminal, on-screen keyboard and home-server
# setup that turns samsung-beyond1lte-downstream into a pocket terminal.
pkgname=s10-terminal
pkgver=1
pkgrel=0
pkgdesc="Galaxy S10 pocket terminal: fbterm + tmux, on-screen keyboard, hardening"
url="https://postmarketos.org"
arch="aarch64"
license="MIT"
depends="
	fbterm
	font-jetbrains-mono
	iptables
	iptables-legacy
	msm-fb-refresher
	ncurses-terminfo
	neovim
	py3-numpy
	py3-pillow
	python3
	tmux
	unudhcpd
	wordgrinder
	"
install="$pkgname.post-install $pkgname.post-upgrade"
options="!check"
EOF
printf 'source="\n'
for f in $files; do printf '\t%s\n' "$f"; done
printf '\t"\n\n'
cat <<'EOF'
package() {
	for f in s10-osk s10-idle-blank s10-touch-absfix s10-osk-start s10-term; do
		install -Dm755 "$srcdir/$f" "$pkgdir/usr/bin/$f"
	done
	install -Dm644 "$srcdir"/fbtermrc "$pkgdir"/usr/share/s10-terminal/fbtermrc
	install -Dm644 "$srcdir"/tmux.conf "$pkgdir"/etc/tmux.conf
	for f in 10-firewall 20-display-on 30-usb-dhcp 40-s10-tuning 50-s10-idle-blank 60-s10-osk; do
		install -Dm755 "$srcdir/$f.start" "$pkgdir/etc/local.d/$f.start"
	done
	install -Dm644 "$srcdir"/90-s10-touch-absfix.rules \
		"$pkgdir"/usr/lib/udev/rules.d/90-s10-touch-absfix.rules
	install -Dm644 "$srcdir"/unudhcpd.rndis0.confd "$pkgdir"/etc/conf.d/unudhcpd.rndis0
	mkdir -p "$pkgdir"/etc/init.d
	ln -s unudhcpd "$pkgdir"/etc/init.d/unudhcpd.rndis0
	install -Dm644 "$srcdir"/wifi-powersave-off.conf \
		"$pkgdir"/etc/NetworkManager/conf.d/10-s10-wifi-powersave-off.conf
	install -Dm644 "$srcdir"/sshd-hardening.conf \
		"$pkgdir"/etc/ssh/sshd_config.d/10-hardening.conf
}

EOF
printf 'sha512sums="\n'
for f in $files; do sha512sum "$f" | sed 's/^/\0/'; done
printf '"\n'
} > APKBUILD
sed -i -E 's/^([0-9a-f]{128})  /\1  /' APKBUILD
grep -c '  ' APKBUILD >/dev/null
ls
cd ~/.local/var/pmbootstrap/cache_git/pmaports
git add device/downstream/s10-terminal
git -c user.name=khan -c user.email=khan@localhost commit -qm "s10-terminal: package the pocket-terminal setup (osk, fbterm session, hardening)"
git log -1 --oneline
