#!/bin/sh
# Replace Sxmo/X with fbterm + tmux on tty1, add idle screen-off, reboot.
# Run with: sudo sh ~/nosxmo.sh
set -e
[ "$(id -u)" = 0 ] || { echo "run with sudo"; exit 1; }

echo "== 1/4 removing Sxmo and X (console UI comes back)"
apk del -q postmarketos-ui-sxmo-de-dwm postmarketos-ui-sxmo-de-dwm-openrc \
	xf86-video-fbdev xf86-input-libinput 2>&1 | tail -3 || true
apk add -q postmarketos-ui-console
apk info -e postmarketos-ui-sxmo-de-dwm >/dev/null 2>&1 && { echo "Sxmo still installed"; exit 1; }
echo "Sxmo removed"

echo "== 2/4 terminal on tty1 at boot (fbterm + tmux, logged in as farmer)"
[ -f /etc/inittab.orig ] || cp /etc/inittab /etc/inittab.orig
sed -i 's|^tty1::respawn:.*|tty1::respawn:/bin/su -l farmer -c /home/farmer/.s10-term.sh|' /etc/inittab
grep '^tty1' /etc/inittab

echo "== 3/4 idle screen-off (2 min; any key, touch or Volume Up wakes)"
install -m 755 /home/farmer/s10-idle-blank /usr/local/bin/s10-idle-blank
cat > /etc/local.d/50-s10-idle-blank.start <<'EOF'
#!/bin/sh
pidof -x s10-idle-blank >/dev/null || setsid /usr/local/bin/s10-idle-blank >/dev/null 2>&1 < /dev/null &
EOF
chmod 755 /etc/local.d/50-s10-idle-blank.start

echo "== 4/4 rebooting in 5 s (terminal and SSH back in ~3 min)"
sleep 5
reboot
