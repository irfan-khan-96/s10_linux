#!/bin/bash
# Inspect the freshly built rootfs for the full S10 setup.
R=~/.local/var/pmbootstrap/chroot_rootfs_samsung-beyond1lte-downstream
ok() { printf "%-48s %s\n" "$1" "$2"; }
tail -n 2 ~/s10-install.log
ok "s10-terminal installed" "$(grep -q '^P:s10-terminal$' $R/lib/apk/db/installed && echo yes || echo NO)"
ok "fbterm r1 (keyboard strip patch)" "$(grep -A1 '^P:fbterm$' $R/lib/apk/db/installed | tail -1)"
ok "kernel" "$(grep -A1 '^P:linux-samsung-beyond1lte-downstream$' $R/lib/apk/db/installed | tail -1)"
ok "firmware (with mfc_fw.bin)" "$(ls $R/lib/firmware/postmarketos/mfc_fw.bin >/dev/null 2>&1 && echo yes || echo NO)"
ok "tty1 line" "$(grep '^tty1' $R/etc/inittab)"
u=$(awk -F: '$3==10000{print $1}' $R/etc/passwd)
ok "user $u groups" "$(awk -F: -v u=$u '$4 ~ "(^|,)"u"(,|$)" {printf "%s ", $1}' $R/etc/group)"
for f in 10-firewall 20-display-on 30-usb-dhcp 40-s10-tuning 50-s10-idle-blank 60-s10-osk; do
	ok "local.d/$f.start" "$([ -x $R/etc/local.d/$f.start ] && echo yes || echo NO)"
done
for s in local msm-fb-refresher unudhcpd.rndis0 sshd networkmanager; do
	l=$(ls $R/etc/runlevels/*/$s 2>/dev/null | head -1)
	ok "service $s" "${l:-NOT ENABLED}"
done
ok "unudhcpd.usb0 disabled" "$(ls $R/etc/runlevels/*/unudhcpd.usb0 >/dev/null 2>&1 && echo 'NO (still enabled)' || echo yes)"
ok "udev touch fix rule" "$([ -f $R/usr/lib/udev/rules.d/90-s10-touch-absfix.rules ] && echo yes || echo NO)"
ok "sshd key-only" "$(grep -c '^PasswordAuthentication no' $R/etc/ssh/sshd_config.d/10-hardening.conf 2>/dev/null)"
ok "ssh keys for $u" "$(cut -d' ' -f3 $R/home/$u/.ssh/authorized_keys 2>/dev/null | tr '\n' ' ')"
ok "image" "$(ls -la ~/.local/var/pmbootstrap/chroot_native/home/pmos/rootfs/*.img | awk '{print $5, $9}')"
