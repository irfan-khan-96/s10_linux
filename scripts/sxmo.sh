#!/bin/sh
# Switch the S10 from the console UI to Sxmo (dwm, X11 on the framebuffer).
# Run with: sudo sh ~/sxmo.sh
set -e
[ "$(id -u)" = 0 ] || { echo "run with sudo"; exit 1; }

echo "== step 1: display refresher"
# The panel only shows a new image when the framebuffer is pushed to it.
rc-update add msm-fb-refresher default >/dev/null
rc-service msm-fb-refresher restart
sleep 3
printf "Look at the phone. Do you see text or a cursor on the screen? [y/n] "
read -r answer
if [ "$answer" != "y" ]; then
	echo "Stopping here: the display path needs more work before a UI makes sense."
	echo "msm-fb-refresher stays enabled; nothing else was changed."
	exit 1
fi

echo "== step 2: installing Sxmo (dwm/X11)"
apk add postmarketos-ui-sxmo-de-dwm postmarketos-ui-sxmo-de-dwm-openrc \
	xf86-video-fbdev xf86-input-libinput
apk del postmarketos-ui-console 2>/dev/null || true

# No /dev/dri on this kernel, so tell Xorg to use the framebuffer directly
mkdir -p /etc/X11/xorg.conf.d
cat > /etc/X11/xorg.conf.d/10-s10-fbdev.conf <<'EOF'
Section "Device"
	Identifier "fbdev"
	Driver "fbdev"
	Option "fbdev" "/dev/fb0"
EndSection
EOF

echo "== done. Reboot to start Sxmo: sudo reboot"
echo "   (SSH and the firewall keep working; Sxmo appears on the screen after boot)"
