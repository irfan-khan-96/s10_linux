#!/bin/sh
# Install the display-fixed kernel on the running S10 and switch to Sxmo (dwm/X11).
# No Download mode needed: boot.img is written to BOOT from the phone itself.
# Run with: sudo sh ~/display.sh
set -e
[ "$(id -u)" = 0 ] || { echo "run with sudo"; exit 1; }
APK=$(ls /home/farmer/linux-samsung-beyond1lte-downstream-*-r4.apk 2>/dev/null | head -1)
[ -n "$APK" ] || { echo "kernel package not found in /home/farmer"; exit 1; }

echo "== 1/5 installing kernel $APK (local build, so --allow-untrusted)"
apk add --allow-untrusted "$APK"
apk info -v 2>/dev/null | grep -qx 'linux-samsung-beyond1lte-downstream-4.14.316-r4' || { echo "kernel r4 not installed"; exit 1; }
echo "kernel r4 installed"

echo "== 2/5 checking the regenerated /boot/boot.img"
IMG=/boot/boot.img
[ -f $IMG ] || { echo "$IMG missing"; exit 1; }
head -c 8 $IMG | grep -q 'ANDROID!' || { echo "$IMG is not an Android boot image"; exit 1; }
[ "$(find $IMG -newer "$APK")" = "$IMG" ] || { echo "$IMG was not regenerated"; exit 1; }
D=sda14
grep -qx PARTNAME=boot /sys/class/block/$D/uevent || { echo "/dev/$D is not the boot partition"; exit 1; }
PART=$(( $(cat /sys/class/block/$D/size) * 512 ))
SIZE=$(stat -c %s $IMG)
[ "$SIZE" -lt "$PART" ] || { echo "boot.img ($SIZE) does not fit BOOT ($PART)"; exit 1; }
echo "boot.img $SIZE bytes, BOOT partition $PART bytes: OK"

echo "== 3/5 writing boot.img to /dev/$D (backup of the old one in /boot/boot.img.prev-sda14)"
dd if=/dev/$D of=/boot/boot.img.prev-sda14 bs=1M count=$(( SIZE / 1048576 + 1 )) 2>/dev/null
dd if=$IMG of=/dev/$D bs=1M conv=fsync 2>/dev/null
cmp -n "$SIZE" $IMG /dev/$D && echo "verified"

echo "== 4/5 display on at boot"
cat > /etc/local.d/20-display-on.start <<'EOF'
#!/bin/sh
# Samsung's DECON starts powered off on Linux; unblank it once at boot.
echo 0 > /sys/class/graphics/fb0/blank
EOF
chmod 755 /etc/local.d/20-display-on.start
rc-update add msm-fb-refresher default >/dev/null

echo "== 5/5 installing Sxmo (dwm/X11 on the framebuffer)"
apk add postmarketos-ui-sxmo-de-dwm postmarketos-ui-sxmo-de-dwm-openrc \
	xf86-video-fbdev xf86-input-libinput
apk del postmarketos-ui-console 2>/dev/null || true
mkdir -p /etc/X11/xorg.conf.d
cat > /etc/X11/xorg.conf.d/10-s10-fbdev.conf <<'EOF'
# No /dev/dri on this kernel: drive the framebuffer directly
Section "Device"
	Identifier "fbdev"
	Driver "fbdev"
	Option "fbdev" "/dev/fb0"
EndSection
Section "Screen"
	Identifier "screen"
	Device "fbdev"
	DefaultDepth 24
EndSection
EOF

echo "== done. Reboot with: sudo reboot"
echo "   If the new kernel does not boot, the old one is in /boot/boot.img.prev-sda14"
